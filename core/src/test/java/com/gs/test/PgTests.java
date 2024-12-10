package com.gs.test;

import org.bitcoinj.base.Address;
import org.bitcoinj.base.Coin;
import org.bitcoinj.base.LegacyAddress;
import org.bitcoinj.base.ScriptType;
import org.bitcoinj.base.internal.ByteUtils;
import org.bitcoinj.core.*;
import org.bitcoinj.crypto.ECKey;
import org.bitcoinj.crypto.SignatureDecodeException;
import org.bitcoinj.crypto.TransactionSignature;
import org.bitcoinj.crypto.internal.CryptoUtils;
import org.bitcoinj.script.Script;
import org.bitcoinj.store.BlockStoreException;
import org.bitcoinj.store.ImportRsBlockStore;
import org.bitcoinj.utils.BlockFileLoader;
import org.bouncycastle.util.encoders.Hex;
import org.eclipse.collections.impl.list.mutable.FastList;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.util.concurrent.atomic.AtomicReference;

import static org.bitcoinj.base.BitcoinNetwork.*;

public class PgTests {

    private static final Logger log = LoggerFactory.getLogger(PgTests.class);

    @Test
    public void loadChain() throws BlockStoreException, PrunedException, IOException {
        final NetworkParameters networkParameters = NetworkParameters.of(TESTNET);
        Context.propagate(new Context(100, Coin.ZERO, false, false));

//        final PostgresExtendedPrunedBlockStore blockStore = new PostgresExtendedPrunedBlockStore(networkParameters,
//                "localhost:5433", "cryptodb", "crypto", "btc#btc", true);
//
        final ImportRsBlockStore blockStore = new ImportRsBlockStore(networkParameters);
//        final ImportBlockStore blockStore = new ImportBlockStore(networkParameters);

        final FullPrunedBlockChain blockChain = new FullPrunedBlockChain(networkParameters, blockStore);

        BlockFileLoader blockFileLoader = new BlockFileLoader(networkParameters.network(), new File("/Volumes/Segate/bitcoinDataTest/testnet3/blocks"));

        for (Block block : blockFileLoader) {
            blockChain.add(block);
        }

        blockStore.saveWork();
        blockStore.close();
    }


    @Test
    public void testResolvePrivKeyFromR () {
        final BigInteger N = new BigInteger(1, Hex.decodeStrict("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141"));
        final NetworkParameters networkParameters = NetworkParameters.of(MAINNET);
        BigInteger r =  new BigInteger(1,ByteUtils.parseHex("0488746b6384486e14ffb0e06e5ccc53974eafbb67dc55351d9ba8e0b83e3e28"));
        BigInteger s2 = new BigInteger(1,ByteUtils.parseHex("5525f4f383e6cdd34eb52a247268a95b53b68c28eee84eaef0c612e7512012bf"));
        BigInteger z2 = new BigInteger(1,ByteUtils.parseHex("0100000000000000000000000000000000000000000000000000000000000000"));
        BigInteger s1 = new BigInteger(1,ByteUtils.parseHex("5525f4f383e6cdd34eb52a247268a95b53b68c28eee84eaef0c612e7512012bf"));
        BigInteger z1 = new BigInteger(1,ByteUtils.parseHex("ccaebae37484007212f89419f04a305ba40f6a8be7be2d70e892928d1ccb6110"));

//        289844626749849600,0,\x0000000000000000000000000000000000000000000000000000000000000053,\x0000000000000000000000000000000000000000000000000000000000000052,\xc6ef7b1537e082908d2b71a8fc5fcb73096fd7694351c1626407cc94f7baee91
//        289844669722198016,0,\x0000000000000000000000000000000000000000000000000000000000000053,\x0000000000000000000000000000000000000000000000000000000000000052,\xccaebae37484007212f89419f04a305ba40f6a8be7be2d70e892928d1ccb6110

        BigInteger kx1 = (z2.min(z1)).divide((s2.min(s1)));
        BigInteger d1 = ((s1.multiply(kx1)).min(z1)).divide(r);
        printKey(networkParameters, d1);
        BigInteger kx2 = (z2.min(z1)).divide((s2.add(s1)));
        BigInteger d2 = ((s1.multiply(kx2)).min(z1)).divide(r);
        printKey(networkParameters, d2);
    }

    private void printKey(NetworkParameters networkParameters, BigInteger d) {
        d = BigInteger.TEN;
        ECKey key = ECKey.fromPrivate(d, false);
        System.out.println(ByteUtils.formatHex(ByteUtils.bigIntegerToBytes(d, 32)));
        System.out.println(key.toAddress(ScriptType.P2PKH, networkParameters.network()));
        System.out.println(key.getPublicKeyAsHex());
        System.out.println(ByteUtils.formatHex(CryptoUtils.sha256hash160(key.getPubKey())));
        key = ECKey.fromPrivate(d, true);
        System.out.println(ByteUtils.formatHex(ByteUtils.bigIntegerToBytes(d, 32)));
        System.out.println(key.toAddress(ScriptType.P2PKH, networkParameters.network()));
        System.out.println(key.getPublicKeyAsHex());
        System.out.println(ByteUtils.formatHex(CryptoUtils.sha256hash160(key.getPubKey())));
    }

    @Test
    public void test_address() {
        final NetworkParameters networkParameters = NetworkParameters.of(MAINNET);
        Script script = Script.parse(ByteUtils.parseHex("a91423e522dfc6656a8fda3d47b4fa53f7585ac758cd87"));
        Address address = script.getToAddress(networkParameters.network(), false);
        log.info(address.toString());
    }

    @Test
    public void test_signature() throws SignatureDecodeException {
        byte[] tr = ByteUtils.parseHex("01000000016cd885c299532c73728d69a476f4a9ed48e27c91292f4404468115184fc8e675000000007500093006020101020101014c6851210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71410778d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc345552ae91ffffffff01409c0000000000001976a91492b8c3a56fac121ddcdffbc85b02fb9ef681038a88ac00000000");
        Transaction t = Transaction.read(ByteBuffer.wrap(tr));
        byte[] raw = ByteUtils.parseHex("00093006020101020101014c6851210378d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71410778d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc345552ae91");

        Script script = Script.parse(raw);

        Script pubScript = Script.parse(ByteUtils.parseHex("a914297992d41203c9a50ad9f2c06f2a169d544c339087"));

        System.out.println(script.chunks());

        ECKey.ECDSASignature sig = TransactionSignature.decodeFromDER(raw);

        System.out.println("r: " + sig.r + " " + ByteUtils.formatHex(ByteUtils.bigIntegerToBytes(sig.r, 32)));
        System.out.println("s: " + sig.s + " " + ByteUtils.formatHex(ByteUtils.bigIntegerToBytes(sig.s, 32)));
        System.out.println("isCanonical: " + sig.isCanonical());

       Transaction transaction = Transaction.read(ByteBuffer.wrap(tr));

        System.out.println(transaction);
        System.out.println(transaction.getInputs().get(0).getScriptSig());

    }

    @Test
    public void sort_csv() throws SignatureDecodeException, IOException {
        for (int i = 0; i < 8; i++) {
            final FastList<Data> lines = new FastList<>(3000000);
            System.out.println("Processing " + i);
            BufferedReader bufferedReader = new BufferedReader(new FileReader("data/r_" + i + ".csv"));
            AtomicReference<String> header = new AtomicReference<>();
            bufferedReader.lines().forEach(l -> {
                if (l.startsWith("input_id")) {
                    header.set(l);
                } else {
                    lines.add(new Data(l));
                }
            });
            bufferedReader.close();
            BufferedWriter blocksWriter = new BufferedWriter(new FileWriter("data/r_" + i + "_final.csv"));
            blocksWriter.write(header.get());
            blocksWriter.newLine();
            final AtomicReference<String> lastLine = new AtomicReference<>("");
            lines.stream().sorted(Data::compareTo).forEachOrdered(
                    k -> {
                        try {
                            String l = k.line;
                            if (!lastLine.get().equals(l)) {
                                blocksWriter.write(l);
                                blocksWriter.newLine();
                                lastLine.set(l);
                            }
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }

                    }
            );
            blocksWriter.close();
        }
    }


    public static class Data implements Comparable<Data> {
        final String line;
        final String id;
        public Data(String s) {
            String[] k = s.split(",");
//            id = Long.valueOf(k[0]);
            id = k[2].substring(2);
            line = s;
        }


        @Override
        public int compareTo(Data o) {
            return id.compareTo(o.id);
        }
    }

}
