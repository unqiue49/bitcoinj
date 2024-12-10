package org.bitcoinj.store;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.json.JsonMapper;
import org.bitcoinj.base.Network;
import org.bitcoinj.base.Sha256Hash;
import org.bitcoinj.base.internal.ByteUtils;
import org.bitcoinj.core.*;
import org.bitcoinj.crypto.ECKey;
import org.eclipse.collections.impl.list.mutable.FastList;
import org.eclipse.collections.impl.map.mutable.UnifiedMap;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.FileWriter;
import java.util.*;
import java.util.stream.Collectors;

public class ImportBlockStore implements FullPrunedBlockStore {

    private final UnifiedMap<Sha256Hash, LocalTransactionOutputIds> openTransactionsMap = new UnifiedMap<>(10000000, 0.95F);

    private final FastList<LocalTransaction> cachedTransactions = new FastList<>(15000);
    private final FastList<LocalTransactionOutputSpend> cachedTransactionOutputs = new FastList<>(85000);
    private final FastList<LocalBlock> listBlocks =  new FastList<>(20);
    private final UnifiedMap<Sha256Hash, StoredBlock> cachedBlocks = new UnifiedMap<>(1000, 1F);
    private final NetworkParameters params;
    private StoredBlock chainHead;
    private StoredBlock verifiedChainHead;

    private final BufferedWriter blocksWriter;
    private BufferedWriter transactionWriter;
    private BufferedWriter transactionOutputWriter;
    
    private final JsonMapper jsonMapper = new JsonMapper();
    
    private final String path = "/home/debian/data";

    public ImportBlockStore(NetworkParameters params) throws BlockStoreException, IOException {
        this.params = params;

        blocksWriter = new BufferedWriter(new FileWriter(path + "/blocks.csv"));
        blocksWriter.write("height,net_id,hash,chainwork,header,wasundoable");
        blocksWriter.newLine();
        initFiles(0);
        createNewStore(params);
    }

    private void initFiles(int index) throws IOException{
        if (transactionWriter != null) {
            transactionWriter.close();
        }
        if (transactionOutputWriter != null) {
            transactionOutputWriter.close();
        }

        transactionWriter = new BufferedWriter(new FileWriter(path + "/transactions" + index + ".csv"));
        transactionWriter.write("transaction_id,version,locktime,hash,inputs,outputs");
        transactionWriter.newLine();
        transactionOutputWriter = new BufferedWriter(new FileWriter(path + "/outputs" + index + ".csv"));
        transactionOutputWriter.write("input_id,output_id");
        transactionOutputWriter.newLine();

        /*
        * store new table transaction_hash (hash, transaction_id) pk (hash, transaction_id) partition by hash
        *
        *
        * blocks
        * transactions with json {id, version, locktime  json with ids}
        * transactions_hash {hash, int8[] transaction_ids} ?? or index
        * addreses {hash, int8[] outputs}
        * outputs_open {int8 details ?}
        * outputs_spend {int8 out, int8 in)
        *
        * transactions {
        *
        * }
        * */
    }

    @Override
    public void close() throws BlockStoreException {
        storeData(true);
        try {
            blocksWriter.close();
            transactionWriter.close();
            transactionOutputWriter.close();
            cachedTransactions.clear();
            openTransactionsMap.clear();
            cachedTransactionOutputs.clear();
            listBlocks.clear();
        } catch (IOException e) {
            throw new BlockStoreException(e);
        }
    }

    private void createNewStore(NetworkParameters params) throws BlockStoreException {
        try {
            // Set up the genesis block. When we start out fresh, it is by
            // definition the top of the chain.
            StoredBlock storedGenesisHeader = new StoredBlock(params.getGenesisBlock().cloneAsHeader(), params.getGenesisBlock().getWork(), 0);
            // The coinbase in the genesis block is not spendable. This is because of how Bitcoin Core inits
            // its database - the genesis transaction isn't actually in the db so its spent flags can never be updated.
            StoredUndoableBlock storedGenesis = new StoredUndoableBlock(params.getGenesisBlock().getHash(), params.getGenesisBlock().getTransactions());
            put(storedGenesisHeader, storedGenesis);
            setChainHead(storedGenesisHeader);
            setVerifiedChainHead(storedGenesisHeader);
        } catch (VerificationException e) {
            throw new RuntimeException(e); // Cannot happen.
        }
    }

    @Override
    public List<UTXO> getOpenTransactionOutputs(List<ECKey> keys) throws UTXOProviderException {
        return null;
    }

    @Override
    public int getChainHeadHeight() throws UTXOProviderException {
        return this.chainHead.getHeight();
    }

    @Override
    public Network network() {
        return params.network();
    }

    @Override
    public void put(StoredBlock block) throws BlockStoreException {

    }

    @Override
    public StoredBlock get(Sha256Hash hash) throws BlockStoreException {
        return cachedBlocks.get(hash);
    }

    @Override
    public StoredBlock getChainHead() throws BlockStoreException {
        return this.chainHead;
    }

    @Override
    public void setChainHead(StoredBlock chainHead) throws BlockStoreException {
        this.chainHead = chainHead;
    }

    @Override
    public void put(StoredBlock storedBlock, StoredUndoableBlock undoableBlock) throws BlockStoreException {
        Sha256Hash blockHash = storedBlock.getHeader().getHash();
        // We skip the first 4 bytes because (on mainnet) the minimum target has 4 0-bytes
        byte[] hashBytes = blockHash.getBytes(); //new byte[28];
//        System.arraycopy(storedBlock.getHeader().getHash().getBytes(), 4, hashBytes, 0, 28);
        int height = storedBlock.getHeight();

        StoredBlock storedBlockCached = cachedBlocks.get(blockHash);
//        LocalBlock storedBlockCached = listBlocks.get(hashBytes);
        if (storedBlockCached != null) {
            return;
        }

        LocalBlock localBlock = new LocalBlock(height,
                (short)params.network().ordinal(),
                hashBytes,
                storedBlock.getChainWork().toByteArray(),
                storedBlock.getHeader().cloneAsHeader().unsafeBitcoinSerialize(),
                false);

        listBlocks.add(localBlock);
        cachedBlocks.put(blockHash, storedBlock);

        if (undoableBlock.getTransactions() == null) {
            return;
        }


        // insert transactions and outputs first
        try {
            long idx = 0;
            for (Transaction transaction : undoableBlock.getTransactions()) {
                long transactionId = ((((long) params.network().ordinal() << 26) + height) << 32) + (idx << 16);
                LocalTransaction lt = new LocalTransaction();

                lt.transactionId = transactionId;
                lt.version = (int) transaction.getVersion();
                lt.lockTime = (int) transaction.getLockTime();
                lt.hash = transaction.getTxId().getBytes();


                List<LocalTransactionOutput> transactionOutputList = new ArrayList<>();
                List<LocalTransactionInput> transactionInputList = new ArrayList<>();

                cachedTransactions.add(lt);
                LocalTransactionOutputIds outputs = new LocalTransactionOutputIds(lt.transactionId);

                long outIdx = 0;
                for (TransactionOutput output : transaction.getOutputs()) {
                    LocalTransactionOutput lOutput = new LocalTransactionOutput();
                    lOutput.id = outIdx; // transactionId + outIdx
                    lOutput.value = output.getValue().value;
                    lOutput.coinbase = transaction.isCoinBase();
                    lOutput.scriptbytes = output.getScriptBytes();

                    transactionOutputList.add(lOutput);
                    outputs.outputs.add(new LocalTransactionOutputSpend(transactionId + outIdx, -1L));
                    outIdx++;
                }


                openTransactionsMap.put(transaction.getTxId(), outputs);

                long inIdx = 0;
                for (TransactionInput input : transaction.getInputs()) {
                    LocalTransactionInput lInput = new LocalTransactionInput();
                    lInput.id = inIdx; // transactionId + inIdx
                    lInput.scriptbytes = input.getScriptBytes();
                    lInput.witnessbytes = null;
                    if (input.isCoinBase()) {
                        lInput.prevOutputId = -1L;
                    } else {
                        if (input.getWitness() != null) {
                            lInput.witnessbytes = input.getWitness().serialize();
                        }
                        LocalTransactionOutputSpend prevOutput = getUnspendOuput(input.getOutpoint().hash(), input.getOutpoint().index());
                        if (prevOutput == null) {
                            throw new BlockStoreException("Transaction output not found");
                        } else {
//                            prevOutput.spend = true;
                            lInput.prevOutputId = prevOutput.transactionInputId;
                            prevOutput.transactionOutputId = transactionId + inIdx;
                            cachedTransactionOutputs.add(prevOutput);
                        }


                    }
                    transactionInputList.add(lInput);
                    inIdx++;
                }

                lt.inputs = jsonMapper.writeValueAsString(transactionInputList);
                lt.outputs = jsonMapper.writeValueAsString(transactionOutputList);

                idx++;
            }



            if (height > 0 && height % 1000 == 0) {
                storeData(true);
                cachedBlocks.values().stream().filter(b -> b.getHeight() < height - 10000).map(z -> z.getHeader().getHash()).collect(Collectors.toList()).forEach(cachedBlocks::remove);
                if (height % 50000 == 0) {
                    initFiles(height / 50000);
                }
            } else if (height % 500 == 0) {
                storeData(true);
            } else if (height % 30 == 0) {
                storeData(false);
            }


        } catch (Exception e) {
             throw new BlockStoreException(e.getMessage());
        }
        undoableBlock.setTransactions(null);
        storedBlock.getHeader().unCacheBlock();
    }

    public void storeData(boolean saveOutputs) {
        listBlocks.forEach(
                b -> {
                    String s = b.height + "," + b.netId + ",\\x" + ByteUtils.formatHex(b.hash) + ",\\x" +
                            ByteUtils.formatHex(b.chainwork) + ",\\x" + ByteUtils.formatHex(b.header) + "," + b.wasundoable;
                    try {
                        blocksWriter.write(s);
                        blocksWriter.newLine();
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }

                }
        );
        listBlocks.clear();

        cachedTransactions.forEach(
                i -> {
                    String s = i.transactionId + "," + i.version + "," + i.lockTime + ",\\x" + ByteUtils.formatHex(i.hash);
                    try {
                        transactionWriter.write(s);
                        transactionWriter.newLine();
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                }
        );

        cachedTransactions.clear();

        if (!saveOutputs) {
            return;
        }

        cachedTransactionOutputs.stream().sorted(LocalTransactionOutputSpend::compareTo).forEachOrdered(
                o -> {
                    String s = o.transactionInputId + "," + o.transactionOutputId;
                    try {
                        transactionOutputWriter.write(s);
                        transactionOutputWriter.newLine();
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                }
        );

        cachedTransactionOutputs.clear();
        System.gc();

    }

    public void saveWork() throws IOException {
        storeData(true);

        BufferedWriter transactionOutputUnspendWriter = new BufferedWriter(new FileWriter(path + "/outputs-open.csv"));
        transactionOutputUnspendWriter.write("input_id");
        transactionOutputUnspendWriter.newLine();

        openTransactionsMap.values().forEach(u-> {
            u.outputs.forEach(o -> {
                String s = String.valueOf(o.transactionInputId);
                try {
                    transactionOutputUnspendWriter.write(s);
                    transactionOutputUnspendWriter.newLine();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });

        });

        transactionOutputUnspendWriter.close();
        try {
            this.close();
        } catch (BlockStoreException e) {
            throw new RuntimeException(e);
        }
    }

    private LocalTransactionOutputSpend getUnspendOuput(Sha256Hash hash, long index) throws BlockStoreException {
        LocalTransactionOutputIds outputIds = openTransactionsMap.get(hash);

        if (outputIds == null) {
            throw new BlockStoreException("Unknown ouput no hash");
        }
        long expectedId = outputIds.transactionId + index;
        int size = outputIds.outputs.size();
        for (int i =0; i < size; i++) {
            if (outputIds.outputs.get(i).transactionInputId == expectedId) {
                LocalTransactionOutputSpend k;
                if (size > 1) {
                    k = outputIds.outputs.remove(i);
                    outputIds.outputs.trimToSize();
                } else {
                    k = outputIds.outputs.get(i);
                    outputIds.outputs.clear();
                    openTransactionsMap.remove(hash);
                }
                return k;
            }
        }
        throw new BlockStoreException("Unknown ouput no id");
    }

    @Override
    public StoredBlock getOnceUndoableStoredBlock(Sha256Hash hash) throws BlockStoreException {
        return null;
    }

    @Override
    public StoredUndoableBlock getUndoBlock(Sha256Hash hash) throws BlockStoreException {
        return null;
    }

    @Override
    public UTXO getTransactionOutput(Sha256Hash hash, long index) throws BlockStoreException {
        return null;
    }

    @Override
    public void addUnspentTransactionOutput(UTXO out) throws BlockStoreException {

    }

    @Override
    public void removeUnspentTransactionOutput(UTXO out) throws BlockStoreException {

    }

    @Override
    public boolean hasUnspentOutputs(Sha256Hash hash, int numOutputs) throws BlockStoreException {
        return false;
    }

    @Override
    public StoredBlock getVerifiedChainHead() throws BlockStoreException {
        return this.verifiedChainHead;
    }

    @Override
    public void setVerifiedChainHead(StoredBlock chainHead) throws BlockStoreException {
        this.verifiedChainHead = chainHead;
    }

    @Override
    public void beginDatabaseBatchWrite() throws BlockStoreException {

    }

    @Override
    public void commitDatabaseBatchWrite() throws BlockStoreException {

    }

    @Override
    public void abortDatabaseBatchWrite() throws BlockStoreException {

    }

    public static class LocalBlock implements Comparable<LocalBlock> {
        int height;
        short netId;
        byte[] hash;
        byte[] chainwork;
        byte[] header;
        boolean wasundoable;

        public LocalBlock(int height, short netId, byte[] hash, byte[] chainwork, byte[] header, boolean wasundoable) {
            this.height = height;
            this.netId = netId;
            this.hash = hash;
            this.chainwork = chainwork;
            this.header = header;
            this.wasundoable = wasundoable;
        }

        @Override
        public int compareTo(LocalBlock o) {
            return Integer.compare(this.height, o.height);
        }
    }

    public static class LocalTransactionHash {
        byte[] hash;
        long transactionId;
    }

    public static class LocalTransaction implements Comparable<LocalTransaction> {
        long transactionId;
        int version;
        int lockTime;
        byte[] hash;
        String inputs;
        String outputs;

        @Override
        public int compareTo(LocalTransaction o) {
            return Long.compare(this.transactionId, o.transactionId);
        }
    }
    
    public static class LocalTransactionOutputSpend implements Comparable<LocalTransactionOutputSpend> {
        long transactionInputId;
        long transactionOutputId;

        public LocalTransactionOutputSpend(long transactionInputId, long transactionOutputId) {
            this.transactionInputId = transactionInputId;
            this.transactionOutputId = transactionOutputId;
        }

        @Override
        public int compareTo(LocalTransactionOutputSpend o) {
            return Long.compare(this.transactionInputId, o.transactionInputId);
        }
    }

    public static class LocalTransactionOutputIds {
        long transactionId;
        FastList<LocalTransactionOutputSpend> outputs;

        public LocalTransactionOutputIds(long transactionId) {
            this.transactionId = transactionId;
            outputs = new FastList<>(1);
        }
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class LocalTransactionInput implements Comparable<LocalTransactionInput>{
        long id;
        long prevOutputId;
        byte[] scriptbytes;
        byte[] witnessbytes;

        @Override
        public int compareTo(LocalTransactionInput o) {
            return Long.compare(this.id, o.id);
        }
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class LocalTransactionOutput implements Comparable<LocalTransactionOutput> {
        long id;
        long value;
        boolean coinbase;
        byte[] scriptbytes;

        @Override
        public int compareTo(LocalTransactionOutput o) {
            return Long.compare(this.id, o.id);
        }
    }
}
