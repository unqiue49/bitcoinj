package org.bitcoinj.store;

import org.bitcoinj.base.Coin;
import org.bitcoinj.base.Network;
import org.bitcoinj.base.Sha256Hash;
import org.bitcoinj.base.internal.ByteUtils;
import org.bitcoinj.core.*;
import org.bitcoinj.crypto.ECKey;
import org.bitcoinj.crypto.TransactionSignature;
import org.bitcoinj.script.*;
import org.eclipse.collections.impl.list.mutable.FastList;
import org.eclipse.collections.impl.map.mutable.UnifiedMap;
import org.eclipse.collections.impl.set.mutable.UnifiedSet;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class ImportRsBlockStore implements FullPrunedBlockStore {

    private final UnifiedMap<String, LocalOutputData> openTransactionsMap = new UnifiedMap<>(10000000, 0.95F);

    private final FastList<LocalR> cachedR = new FastList<>(100);
    private final UnifiedMap<Sha256Hash, StoredBlock> cachedBlocks = new UnifiedMap<>(5000, 1F);
    private final NetworkParameters params;
    private StoredBlock chainHead;
    private StoredBlock verifiedChainHead;
    private BufferedWriter[] rWriters;

    private long lastUnspendTransactionOutputId = 0;

    protected ThreadLocal<Connection> conn;
    private final List<Connection> allConnections;
    private final String connectionURL;
    private final String username = "crypto";
    private final String password = "btc#btc";
    private static final String SELECT_OPEN_OUTPUT = "select output_id from transaction_outputs_open_btc_test where (output_id between ? and ?) and spend = false";

    public ImportRsBlockStore(NetworkParameters params) throws BlockStoreException, IOException {
        this.params = params;

        this.connectionURL = "jdbc:postgresql://localhost:5433/cryptodb";
        this.conn = new ThreadLocal<>();
        this.allConnections = new LinkedList<>();
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {

        }
        maybeConnect();
        initFiles();
        createNewStore(params);
    }

    private synchronized void maybeConnect() throws BlockStoreException {
        try {
            if (conn.get() != null && !conn.get().isClosed())
                return;

            if (username == null || password == null) {
                conn.set(DriverManager.getConnection(connectionURL));
            } else {
                Properties props = new Properties();
                props.setProperty("user", this.username);
                props.setProperty("password", this.password);
                conn.set(DriverManager.getConnection(connectionURL, props));
            }
            allConnections.add(conn.get());
        } catch (SQLException ex) {
            throw new BlockStoreException(ex);
        }
    }

    private Set<Long> getFinalOpenOutput(long a, long b) throws BlockStoreException {
        UnifiedSet<Long> result = new UnifiedSet<>(10000);
        PreparedStatement getTr = null;
        try {
            getTr = conn.get().prepareStatement(SELECT_OPEN_OUTPUT);
            getTr.setLong(1, a);
            getTr.setLong(2, b);
            ResultSet rs = getTr.executeQuery();
            while (rs.next()) {
                result.add(rs.getLong(1));
            }
            rs.close();
            return result;
        } catch (SQLException e) {
            throw new BlockStoreException(e);
        } finally {
            if (getTr != null) {
                try {
                    getTr.close();
                } catch (SQLException e) {
                    throw new RuntimeException(e);
                }
            }
        }
    }

    private void initFiles() {
        rWriters = IntStream.range(0, 32).boxed().map(i -> {
            try {
                return new BufferedWriter(new FileWriter("/Volumes/Segate/data/r_"+ i +".csv"));
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }).toArray(BufferedWriter[]::new);
        Arrays.stream(rWriters).forEach(r -> {
            try {
                r.write("input_id,prefix,r,s,sighash");
                r.newLine();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

        });

    }

    @Override
    public void close() throws BlockStoreException {
        storeData();
        try {
            Arrays.stream(rWriters).forEach(r -> {
                try {
                    r.close();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });
        } catch (Exception e) {
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

        cachedBlocks.put(blockHash, storedBlock);

        if (undoableBlock.getTransactions() == null) {
            return;
        }


        // insert transactions and outputs first
        try {
            long idx = 0;
            for (Transaction transaction : undoableBlock.getTransactions()) {
                long transactionId = ((((long) params.network().ordinal() << 26) + height) << 32) + (idx << 16);

                long idu = 0;
                for (TransactionOutput o: transaction.getOutputs()) {
                    long outputId = transactionId + idu;
                    LocalOutputData d;
                    try {
                        d =new LocalOutputData(outputId, o.getScriptPubKey(), o.getValue());
                    } catch (ScriptException e) {
                        d = new LocalOutputData(outputId, null, o.getValue());
                    }

                    String key = transaction.getTxId().toString() + "-" + idu;
                    openTransactionsMap.put(key, d);

                    idu++;
                }

                if (!transaction.isCoinBase()) {
                    long inIdx = 0;
                    for (TransactionInput input : transaction.getInputs()) {
                        createLocalR(input, transactionId + inIdx);
                        inIdx++;
                    }
                }
                idx++;
            }

            if (height > 0 && height % 1000 == 0) {
                storeData();
                if (height >= 50000) {
                    cachedBlocks.values().stream().filter(b -> b.getHeight() < height - 4000).map(z -> z.getHeader().getHash()).collect(Collectors.toList()).forEach(cachedBlocks::remove);
                    if (height <= 100001) {
                        cachedBlocks.trimToSize();
                    }

                    if (height % 25000 == 0) {
                        long transactionBeforeId = ((((long) params.network().ordinal() << 26) + (height-25000)) << 32);
                        AtomicInteger z = new AtomicInteger();
                        Set<Long> outputs = getFinalOpenOutput(lastUnspendTransactionOutputId, transactionBeforeId);
                        openTransactionsMap.removeIf((k, v) -> {
                            if (v.outputId >= lastUnspendTransactionOutputId && v.outputId <= transactionBeforeId) {
                                if (outputs.contains(v.outputId)) {
                                    z.getAndIncrement();
                                    return true;
                                }
                            }
                            return false;
                        });
                        System.out.println("REMOVE UNSPENDED " + z.get());
                        lastUnspendTransactionOutputId = transactionBeforeId;
                    }
                    System.gc();
                }
            } else {
                storeData();
            }


        } catch (Exception e) {
            System.err.println(e.getMessage());
            e.printStackTrace();
             throw new BlockStoreException(e.getMessage());
        }
        undoableBlock.setTransactions(null);
        storedBlock.getHeader().unCacheBlock();
    }

    public void storeData() {
        cachedR.forEach(
                r -> {
                    int prefix = r.r[0] & 0xff;
                    int prefix_full = prefix * 256 + (r.r[1] & 0xff);
                    String s = r.inputId + "," + prefix_full + ",\\x" + ByteUtils.formatHex(r.r) + ",\\x" +
                            ByteUtils.formatHex(r.s) + ",\\x" + ByteUtils.formatHex(r.sigHash);

                    try {
                        prefix = prefix >> 5;
                        rWriters[prefix].write(s);
                        rWriters[prefix].newLine();
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }

                }
        );
        cachedR.clear();

    }

    public void saveWork() throws IOException {
        storeData();
    }

    private void createLocalR(TransactionInput input, long inputId) {
        String key = input.getOutpoint().hash().toString() + "-" + input.getOutpoint().index();

        LocalOutputData localOutputData = openTransactionsMap.remove(key);

        Script scriptPubKey = localOutputData.script;
        if (scriptPubKey == null) {
            return;
        }
        Coin value = localOutputData.value;

        Script sigScript = input.getScriptSig();
        Transaction txContainingThis = input.getParentTransaction();
        try {
            sigScript.correctlySpends(txContainingThis, input.getIndex(), input.getWitness(), value, scriptPubKey, Script.ALL_VERIFY_FLAGS);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        if (Script.sigHashList.isEmpty()) {
            Script.sigHashList.add(Script.sigHash);
            Script.signatureList.add(Script.signature);
        }

        for (int i = 0; i < Script.signatureList.size(); i++) {
            TransactionSignature signature = Script.signatureList.get(i);
            if (signature == null || signature.s == null || signature.r == null) {
                continue;
            }
            Sha256Hash sigHash = Script.sigHashList.get(i);

            if (sigHash == null) {
                continue;
            }

            LocalR localR = new LocalR();
            localR.inputId = inputId;
//            BigInteger rx = (signature.r.add(sigHash.toBigInteger())).divide(signature.s);
//            System.out.println("rx " + rx);
            localR.r = ByteUtils.bigIntegerToBytes(signature.s, 32);
            localR.s = ByteUtils.bigIntegerToBytes(signature.r, 32);
            localR.sigHash = sigHash.getBytes();

            cachedR.add(localR);
        }

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

    public static class LocalOutputData {
        long outputId;
        Script script;
        Coin value;

        public LocalOutputData(long outputId, Script script, Coin value) {
            this.outputId = outputId;
            this.script = script;
            this.value = value;
        }
    }

    public static class LocalR implements Comparable<LocalR>{
        long inputId;
        byte[] r;
        byte[] s;
        byte[] sigHash;

        @Override
        public int compareTo(LocalR o) {
            for (int i = 32 - 1; i >= 0; i--) {
                final int thisByte = this.r[i] & 0xff;
                final int otherByte = o.r[i] & 0xff;
                if (thisByte > otherByte)
                    return 1;
                if (thisByte < otherByte)
                    return -1;
            }
            return 0;
        }
    }

}
