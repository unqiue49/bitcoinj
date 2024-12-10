package com.gs.test;

import org.bitcoinj.base.Coin;
import org.bitcoinj.core.*;
import org.bitcoinj.store.BlockStoreException;
import org.bitcoinj.store.ImportBlockStore;
import org.bitcoinj.utils.BlockFileLoader;

import java.io.File;
import java.io.IOException;

import static org.bitcoinj.base.BitcoinNetwork.MAINNET;

public class FileImporter {
    static final NetworkParameters networkParameters = NetworkParameters.of(MAINNET);

    public static void main(String[] args) throws BlockStoreException, IOException, PrunedException {
        System.err.println("STARTED");
        Context.propagate(new Context(100, Coin.ZERO, false, false));

        final ImportBlockStore blockStore = new ImportBlockStore(networkParameters);
        final FullPrunedBlockChain blockChain = new FullPrunedBlockChain(networkParameters, blockStore);

        try {
            BlockFileLoader blockFileLoader = new BlockFileLoader(networkParameters.network(), new File("/home/bitcoin/blocks/blocks"));

            int i = 1;
            for (Block block : blockFileLoader) {
                System.err.println("Block: #" + i + " " + block.getHashAsString());
                blockChain.add(block);
                i++;
            }
        } finally {
            blockStore.saveWork();
            blockStore.close();
        }
        System.err.println("DONE");
    }
}
