/*
 * Copyright 2012 Matt Corallo.
 * Copyright 2014 Andreas Schildbach
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.bitcoinj.core;

import org.bitcoinj.base.Sha256Hash;
import org.bitcoinj.store.BlockStoreException;
import org.bitcoinj.store.FullPrunedBlockStore;
import org.bitcoinj.wallet.Wallet;
import org.bitcoinj.wallet.WalletExtension;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.*;

import static org.bitcoinj.base.internal.Preconditions.checkState;

/**
 * <p>A FullPrunedBlockChain works in conjunction with a {@link FullPrunedBlockStore} to verify all the rules of the
 * Bitcoin system, with the downside being a large cost in system resources. Fully verifying means all unspent
 * transaction outputs are stored. Once a transaction output is spent and that spend is buried deep enough, the data
 * related to it is deleted to ensure disk space usage doesn't grow forever. For this reason a pruning node cannot
 * serve the full block chain to other clients, but it nevertheless provides the same security guarantees as Bitcoin
 * Core does.</p>
 */
public class FullPrunedBlockForImportChain extends AbstractBlockChain {
    private static final Logger log = LoggerFactory.getLogger(FullPrunedBlockForImportChain.class);

    /**
     * Keeps a map of block hashes to StoredBlocks.
     */
    protected final FullPrunedBlockStore blockStore;

    /**
     * Constructs a block chain connected to the given wallet and store. To obtain a {@link Wallet} you can construct
     * one from scratch, or you can deserialize a saved wallet from disk using
     * {@link Wallet#loadFromFile(File, WalletExtension...)}
     */
    public FullPrunedBlockForImportChain(NetworkParameters params, Wallet wallet, FullPrunedBlockStore blockStore) throws BlockStoreException {
        this(params, Collections.singletonList(wallet), blockStore);
    }

    /**
     * Constructs a block chain connected to the given store.
     */
    public FullPrunedBlockForImportChain(NetworkParameters params, FullPrunedBlockStore blockStore) throws BlockStoreException {
        this(params, Collections.emptyList(), blockStore);
    }

    /**
     * Constructs a block chain connected to the given list of wallets and a store.
     */
    public FullPrunedBlockForImportChain(NetworkParameters params, List<Wallet> listeners,
                                         FullPrunedBlockStore blockStore) throws BlockStoreException {
        super(params, listeners, blockStore);
        this.blockStore = blockStore;
        // Ignore upgrading for now
        this.chainHead = blockStore.getVerifiedChainHead();
    }

    @Override
    protected StoredBlock addToBlockStore(StoredBlock storedPrev, Block header, TransactionOutputChanges txOutChanges)
            throws BlockStoreException, VerificationException {
        StoredBlock newBlock = storedPrev.build(header);
        blockStore.put(newBlock, new StoredUndoableBlock(newBlock.getHeader().getHash(), txOutChanges));
        return newBlock;
    }

    @Override
    protected StoredBlock addToBlockStore(StoredBlock storedPrev, Block block)
            throws BlockStoreException, VerificationException {
        StoredBlock newBlock = storedPrev.build(block);
        blockStore.put(newBlock, new StoredUndoableBlock(newBlock.getHeader().getHash(), block.getTransactions()));
        return newBlock;
    }

    @Override
    protected void rollbackBlockStore(int height) throws BlockStoreException {
        throw new BlockStoreException("Unsupported");
    }

    @Override
    protected boolean shouldVerifyTransactions() {
        return false;
    }

    /**
     * Whether or not to run scripts whilst accepting blocks (i.e. checking signatures, for most transactions).
     * If you're accepting data from an untrusted node, such as one found via the P2P network, this should be set
     * to true (which is the default). If you're downloading a chain from a node you control, script execution
     * is redundant because you know the connected node won't relay bad data to you. In that case it's safe to set
     * this to false and obtain a significant speedup.
     */
    @Override
    protected TransactionOutputChanges connectTransactions(int height, Block block)
            throws VerificationException, BlockStoreException {
        return null;
    }

    /**
     * Used during reorgs to connect a block previously on a fork
     */
    @Override
    protected synchronized TransactionOutputChanges connectTransactions(StoredBlock newBlock)
            throws VerificationException, BlockStoreException, PrunedException {
        return null;
    }

    /**
     * This is broken for blocks that do not pass BIP30, so all BIP30-failing blocks which are allowed to fail BIP30
     * must be checkpointed.
     */
    @Override
    protected void disconnectTransactions(StoredBlock oldBlock) throws PrunedException, BlockStoreException {
        checkState(lock.isHeldByCurrentThread());
        blockStore.beginDatabaseBatchWrite();
        try {
            StoredUndoableBlock undoBlock = blockStore.getUndoBlock(oldBlock.getHeader().getHash());
            if (undoBlock == null) throw new PrunedException(oldBlock.getHeader().getHash());
            TransactionOutputChanges txOutChanges = undoBlock.getTxOutChanges();
            for (UTXO out : txOutChanges.txOutsSpent)
                blockStore.addUnspentTransactionOutput(out);
            for (UTXO out : txOutChanges.txOutsCreated)
                blockStore.removeUnspentTransactionOutput(out);
        } catch (PrunedException | BlockStoreException e) {
            blockStore.abortDatabaseBatchWrite();
            throw e;
        }
    }

    @Override
    protected void doSetChainHead(StoredBlock chainHead) throws BlockStoreException {
        checkState(lock.isHeldByCurrentThread());
        blockStore.setVerifiedChainHead(chainHead);
        blockStore.commitDatabaseBatchWrite();
    }

    @Override
    protected void notSettingChainHead() throws BlockStoreException {
        blockStore.abortDatabaseBatchWrite();
    }

    @Override
    protected StoredBlock getStoredBlockInCurrentScope(Sha256Hash hash) throws BlockStoreException {
        checkState(lock.isHeldByCurrentThread());
        return blockStore.getOnceUndoableStoredBlock(hash);
    }

}
