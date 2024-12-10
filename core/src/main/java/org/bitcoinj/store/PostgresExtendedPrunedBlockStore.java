package org.bitcoinj.store;

import org.bitcoinj.base.Coin;
import org.bitcoinj.base.Network;
import org.bitcoinj.base.ScriptType;
import org.bitcoinj.base.Sha256Hash;
import org.bitcoinj.base.internal.ByteUtils;
import org.bitcoinj.core.*;
import org.bitcoinj.crypto.ECKey;
import org.bitcoinj.script.Script;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.postgresql.copy.CopyManager;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;

public class PostgresExtendedPrunedBlockStore implements FullPrunedBlockStore {

    private static final String CHAIN_HEAD_SETTING = "chainhead";
    private static final String VERIFIED_CHAIN_HEAD_SETTING = "verifiedchainhead";
    private static final String VERSION_SETTING = "version";
    private static final String SELECT_SETTINGS_SQL = "SELECT count(1) FROM settings";
    private static final String INSERT_SETTINGS_SQL = "INSERT INTO settings(name, value) VALUES(?, ?)";
    private static final String UPDATE_SETTINGS_SQL = "UPDATE settings SET value = ? WHERE name = ?";
    private static final String SELECT_SETTINGS_BY_NAME_SQL = "SELECT value FROM settings WHERE name = ?";
    private static final String INSERT_BLOCKS_SQL = "INSERT INTO blocks(height, net_id, hash, chainwork, header, wasundoable) VALUES(?, ?, ?, ?, ?, ?)";
    private static final String UPDATE_BLOCKS_SQL = "UPDATE blocks SET wasundoable=? WHERE hash=?";
    private static final String SELECT_BLOCKS_SQL = "SELECT chainwork, height, header, wasundoable FROM blocks WHERE hash = ?";

    private static final String SELECT_BLOCKS_DATA_SQL = "SELECT txoutchanges, transactions FROM blocks_data WHERE hash = ?";
    private static final String SELECT_BLOCKS_DATA_EXISTS_SQL = "select 1 from blocks_data where hash = ?";
    private static final String INSERT_BLOCKS_DATA_SQL = "INSERT INTO blocks_data(hash, txoutchanges, transactions) VALUES(?, ?, ?)";
    private static final String UPDATE_BLOCKS_DATA_SQL = "UPDATE blocks_data SET txoutchanges=?, transactions=? WHERE hash = ?";
    //
    private static final String INSERT_TRANSACTION_SQL = "insert into transactions(transaction_id, version, locktime, hash) values (?, ?, ?, ?)";

    private static final String INSERT_TRANSACTION_INPUT_SQL = "SELECT connect_transaction(?, ?, ?, ?, ?, ?)";
    private static final String INSERT_TRANSACTION_INPUT_SIMPLE_SQL = "insert into transaction_inputs (transaction_id, spend_transaction_id, \"index\", spend_index, scriptbytes, witnessbytes) values (?, ?, ?, ?, ?, ?)";
    private static final String UPDATE_TRANSACTION_AS_SPENDED_SQL = "update transaction_outputs set spend = true where transaction_id = ? and \"index\" = ? and spend = false";
    private static final String INSERT_TRANSACTION_OUTPUT_SQL = "INSERT INTO transaction_outputs_open(transaction_id, value, index, coinbase, spend, criptbytes) VALUES (?, ?, ?, ?, ?, ?)";

    private static final String COMPACT_BLOCKS_SQL = "SELECT compact_blocks(?)";

    // TODO
    private static final String SELECT_TRANSACTION_OUTPUTS_SQL = "SELECT hash, value, scriptbytes, height, index, coinbase, toaddress, scripttype FROM openoutputs where toaddress = ?";

    private static final String SELECT_OPENOUTPUTS_SQL = "SELECT height, value, scriptbytes, coinbase, toaddress, scripttype FROM openoutputs WHERE hash = ? AND index = ?";
    private static final String SELECT_EXISTS_OPEN_TRANSACTION = "select count(1) from transactions t where t.hash = ? and not exists (select 1 from transaction_inputs i where i.spend_transaction_id = t.transaction_id)";
    private static final String UPDATE_TRANSACTION_OUTPUT_AS_SPEND_SQL = "UPDATE transaction_outputs SET spend = true WHERE transaction_id = ? AND index = ?";

    private static final String SELECT_TRANSACTIONS_TO_CHANGE_OLD = "select t.hash, t.transaction_id from transactions t where exists (select count(1) from transaction_outputs to2 where to2.transaction_id = t.transaction_id and to2.spend = false group by to2.transaction_id having count(1) > 1)";
    private static final String SELECT_TRANSACTIONS_TO_CHANGE = "select encode(hash::bytea, 'hex'), transaction_id from unspend_transactions";

    private static final String SELECT_TRANSACTIONS_ID_BY_HASH = "select transaction_id from unspend_transactions where hash = ?";

    private static final String INSERT_TRANSACTION_TMP_TABLE_STAGE0 = "truncate table transactions_tmp_2";
    private static final String INSERT_TRANSACTION_TMP_TABLE_STAGE1 = "with dl1 as (delete from transactions_tmp where transaction_id <= (select max(transaction_id) from transactions_tmp) returning * ) insert into transactions_tmp_2 select * from dl1";
    private static final String INSERT_TRANSACTION_TMP_TABLE_STAGE2 = "insert into transactions select * from transactions_tmp_2 order by 1,2";
    //
//    private static final String INSERT_PRIVATEKEYS_SQL = "INSERT INTO privatekeys (address, privatekey,correct,compressed,base) VALUES (?,?,?,?,?)";
//    private static final String INSERT_PARAMSR_SQL = "INSERT INTO params_r (r, n) VALUES (?,?)";

//    private static final String SELECT_DETIAL_PAIR_R =
//            " select h.hash blockHash, t.hash transactionHash,h.hash prevBlockHash, tprev.hash prevTransactionHash, ou.scriptbytes prevScript, c.index, c.prevIndex\n"+
//                    ",c.scriptbytes inputScript\n"+
//                    "from transactions t\n"+
//                    "join headers h on h.height = t.height\n"+
//                    "join connectedtransactions c on c.transactionid = t.id\n"+
//                    "join outtransactions ou on ou.transactionid = c.prevtransactionid and ou.index = c.previndex\n"+
//                    "join transactions tprev on tprev.id = ou.transactionid\n"+
//                    "join headers hprev on hprev.height = tprev.height\n"+
//                    "where t.id = ? and c.index = ?";
//
//    private static final String SELECT_ALL_PAIR_R = "select address, string_agg(transactionid||'-'||index,',') from temp_r_double_address GROUP BY encode,address HAVING count(1)>1 order by 1";


    private static final String POSTGRES_DUPLICATE_KEY_ERROR_CODE = "23505";
    private static final Logger log = LoggerFactory.getLogger(PostgresExtendedPrunedBlockStore.class);

    private final NetworkParameters params; // MainNetParams.get();
    private Sha256Hash chainHeadHash;
    private StoredBlock chainHeadBlock;
    private Sha256Hash verifiedChainHeadHash;
    private StoredBlock verifiedChainHeadBlock;
    protected ThreadLocal<Connection> conn;
    private final List<Connection> allConnections;
    private final String connectionURL;
    private final String username;
    private final String password;

    private final LinkedHashMap<Sha256Hash, StoredBlock> cachedBlocks = new LinkedHashMap<>();
    private final LinkedHashMap<String, Long> cachedTransactionHashes = new LinkedHashMap<>();
    private final LinkedList<LocalTransaction> cachedTransactions = new LinkedList<>();
    private final LinkedList<LocalTransactionInput> cachedTransactionInputs = new LinkedList<>();
    private final LinkedHashMap<String, LocalTransactionOutput> cachedTransactionOutputs = new LinkedHashMap<>();
    private final LinkedList<LocalTransactionOutputId> cachedLocalTransactionOutputId = new LinkedList<>();

    public PostgresExtendedPrunedBlockStore(NetworkParameters params, String hostname, String dbName,
                                            String username, String password, boolean initCache) {
        this.params = params;

        this.connectionURL = "jdbc:postgresql://" + hostname + "/" + dbName;
        this.username = username;
        this.password = password;
        this.conn = new ThreadLocal<>();
        this.allConnections = new LinkedList<>();
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            log.error("check CLASSPATH for database driver jar ", e);
        }

        try {
            maybeConnect();
            initialize();
            if (initCache)
                initTransactionCache();
        } catch (BlockStoreException e) {
            log.error("Error", e);
        }
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
            log.info("Made a new connection to database " + connectionURL);
        } catch (SQLException ex) {
            throw new BlockStoreException(ex);
        }
    }

    private void initialize() {
        // insert the initial settings for this store
        try {
            PreparedStatement pCheck = conn.get().prepareStatement(SELECT_SETTINGS_SQL);
            ResultSet rs = pCheck.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                rs.close();
                pCheck.close();
                loadChainHeadBlock();
                return;
            }
            rs.close();
            pCheck.close();

            PreparedStatement ps = conn.get().prepareStatement(INSERT_SETTINGS_SQL);
            ps.setString(1, CHAIN_HEAD_SETTING);
            ps.setNull(2, Types.BINARY);
            ps.execute();
            ps.setString(1, VERIFIED_CHAIN_HEAD_SETTING);
            ps.setNull(2, Types.BINARY);
            ps.execute();
            ps.setString(1, VERSION_SETTING);
            ps.setBytes(2, "03".getBytes());
            ps.execute();
            ps.close();
            createNewStore(params);
        } catch (SQLException | BlockStoreException e) {
            log.warn("Configuration already created.");
            throw new RuntimeException(e);
        }
    }

    private void initTransactionCache() {
        // insert the initial settings for this store
        try {
            cachedTransactionHashes.clear();
            PreparedStatement pCheck = conn.get().prepareStatement(SELECT_TRANSACTIONS_TO_CHANGE);
            ResultSet rs = pCheck.executeQuery();
            while (rs.next()) {
                cachedTransactionHashes.put(rs.getString(1), rs.getLong(2));
            }
            rs.close();
            pCheck.close();
        } catch (SQLException e) {
            log.warn("Configuration already created.");
            throw new RuntimeException(e);
        }
    }
    /**
     * Create a new store for the given {@link NetworkParameters}.
     * @param params The network.
     * @throws BlockStoreException If the store couldn't be created.
     */
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

    private void loadChainHeadBlock() throws BlockStoreException {
        try {
            PreparedStatement pSettings = conn.get().prepareStatement(SELECT_SETTINGS_BY_NAME_SQL);
            pSettings.setString(1, CHAIN_HEAD_SETTING);
            ResultSet rs = pSettings.executeQuery();
            if (rs.next()) {
                Sha256Hash chainHeadHash1 = Sha256Hash.wrap(rs.getBytes(1));
                chainHeadBlock = this.get(chainHeadHash1);
                chainHeadHash = chainHeadHash1;
            }
            rs.close();

            pSettings.setString(1, VERIFIED_CHAIN_HEAD_SETTING);
            rs = pSettings.executeQuery();
            if (rs.next()) {
                Sha256Hash verifiedChainHeadHash1 = Sha256Hash.wrap(rs.getBytes(1));
                verifiedChainHeadBlock = this.get(verifiedChainHeadHash1);
                verifiedChainHeadHash = verifiedChainHeadHash1;
            }
            rs.close();
            pSettings.close();
        } catch (SQLException e) {
            throw new BlockStoreException(e);
        }
    }

    @Override
    public List<UTXO> getOpenTransactionOutputs(List<ECKey> keys) throws UTXOProviderException {
        PreparedStatement s = null;
        List<UTXO> outputs = new ArrayList<>();
        try {
            maybeConnect();
            s = conn.get().prepareStatement(SELECT_TRANSACTION_OUTPUTS_SQL);
            for (ECKey key : keys) {
                // TODO switch to pubKeyHash in order to support native segwit addresses
                s.setString(1, key.toAddress(ScriptType.P2PKH, params.network()).toString());
                ResultSet rs = s.executeQuery();
                while (rs.next()) {
                    Sha256Hash hash = Sha256Hash.wrap(rs.getBytes(1));
                    Coin amount = Coin.valueOf(rs.getLong(2));
                    byte[] scriptBytes = rs.getBytes(3);
                    int height = rs.getInt(4);
                    int index = rs.getInt(5);
                    boolean coinbase = rs.getBoolean(6);
                    String toAddress = rs.getString(7);
                    UTXO output = new UTXO(hash,
                            index,
                            amount,
                            height,
                            coinbase,
                            Script.parse(scriptBytes),
                            toAddress);
                    outputs.add(output);
                }
            }
            return outputs;
        } catch (SQLException | BlockStoreException ex) {
            throw new UTXOProviderException(ex);
        } finally {
            if (s != null)
                try {
                    s.close();
                } catch (SQLException e) {
                    throw new UTXOProviderException("Could not close statement", e);
                }
        }
    }

    @Override
    public int getChainHeadHeight() throws UTXOProviderException {
        try {
            return getVerifiedChainHead().getHeight();
        } catch (BlockStoreException e) {
            throw new UTXOProviderException(e);
        }
    }

    @Override
    public Network network() {
        return params.network();
    }

    protected void putUpdateStoredBlock(StoredBlock storedBlock, boolean wasUndoable) throws SQLException {
        byte[] hashBytes = storedBlock.getHeader().getHash().getBytes(); //new byte[28];
        try {
            PreparedStatement s = conn.get().prepareStatement(INSERT_BLOCKS_SQL);
            // We skip the first 4 bytes because (on mainnet) the minimum target has 4 0-bytes
//            System.arraycopy(storedBlock.getHeader().getHash().getBytes(), 4, hashBytes, 0, 28);

            s.setInt(1, storedBlock.getHeight());
            s.setShort(2, (short)params.network().ordinal());
            s.setBytes(3, hashBytes);
            s.setBytes(4, storedBlock.getChainWork().toByteArray());
            s.setBytes(5, storedBlock.getHeader().cloneAsHeader().serialize());
            s.setBoolean(6, wasUndoable);
            s.executeUpdate();
            s.close();

        } catch (SQLException e) {
            // It is possible we try to add a duplicate StoredBlock if we upgraded
            // In that case, we just update the entry to mark it wasUndoable
            if (!(e.getSQLState().equals(POSTGRES_DUPLICATE_KEY_ERROR_CODE)) || !wasUndoable)
                throw e;

            PreparedStatement s = conn.get().prepareStatement(UPDATE_BLOCKS_SQL);
            s.setBoolean(1, true);
            // We skip the first 4 bytes because (on mainnet) the minimum target has 4 0-bytes
//            byte[] hashBytes = new byte[28];
//            System.arraycopy(storedBlock.getHeader().getHash().getBytes(), 4, hashBytes, 0, 28);
            s.setBytes(2, hashBytes);
            s.executeUpdate();
            s.close();
        }
    }

    @Override
    public void put(StoredBlock storedBlock) throws BlockStoreException {
        maybeConnect();
        try {
            putUpdateStoredBlock(storedBlock, false);
        } catch (SQLException e) {
            throw new BlockStoreException(e);
        }
    }

    private Long getTransactionId(byte[] hash) throws BlockStoreException {
        PreparedStatement getTr = null;
        try {
            getTr = conn.get().prepareStatement(SELECT_TRANSACTIONS_ID_BY_HASH);
            getTr.setBytes(1, hash);
            ResultSet rs = getTr.executeQuery();
            if (rs.next()) {
                rs.close();
                return rs.getLong(1);
            }
            rs.close();
            return null;
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

    @Override
    public void put(StoredBlock storedBlock, StoredUndoableBlock undoableBlock) throws BlockStoreException {
        maybeConnect();
        Sha256Hash blockHash = storedBlock.getHeader().getHash();
        // We skip the first 4 bytes because (on mainnet) the minimum target has 4 0-bytes
        byte[] hashBytes = blockHash.getBytes(); //new byte[28];
//        System.arraycopy(storedBlock.getHeader().getHash().getBytes(), 4, hashBytes, 0, 28);
        int height = storedBlock.getHeight();
        byte[] transactions = null;
        byte[] txOutChanges = null;
        try {
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            if (undoableBlock.getTxOutChanges() != null) {
                undoableBlock.getTxOutChanges().serializeToStream(bos);
                txOutChanges = bos.toByteArray();
            } else {
                int numTxn = undoableBlock.getTransactions().size();
                ByteUtils.writeInt32LE(numTxn, bos);
                for (Transaction tx : undoableBlock.getTransactions())
                    tx.bitcoinSerializeToStream(bos);
                transactions = bos.toByteArray();
            }
            bos.close();
        } catch (IOException e) {
            throw new BlockStoreException(e);
        }

        StoredBlock storedBlockCached = cachedBlocks.get(blockHash);
        if (storedBlockCached != null) {
            return;
        }

        if (height % 10000 == 0) {
            compactBlocks(params.network().ordinal());
        }

        try {
            if (log.isDebugEnabled())
                log.debug("Looking for undoable block with hash: " + ByteUtils.formatHex(hashBytes));

            PreparedStatement findS = conn.get().prepareStatement(SELECT_BLOCKS_DATA_EXISTS_SQL);
            findS.setBytes(1, hashBytes);

            ResultSet rs = findS.executeQuery();
            if (rs.next())
            {
                // We already have this output, update it.
                findS.close();

                // Postgres insert-or-updates are very complex (and finnicky).  This level of transaction isolation
                // seems to work for bitcoinj
                PreparedStatement s =
                        conn.get().prepareStatement(UPDATE_BLOCKS_DATA_SQL);
                s.setBytes(3, hashBytes);

                if (log.isDebugEnabled())
                    log.debug("Updating undoable block with hash: " + ByteUtils.formatHex(hashBytes));

                if (transactions == null) {
                    s.setBytes(1, txOutChanges);
                    s.setNull(2, Types.BINARY);
                } else {
                    s.setNull(1, Types.BINARY);
                    s.setBytes(2, transactions);
                }
                s.executeUpdate();
                s.close();

                return;
            }

//            PreparedStatement s = conn.get().prepareStatement(INSERT_BLOCKS_DATA_SQL);
//            s.setBytes(1, hashBytes);
//
//            if (log.isDebugEnabled())
//                log.debug("Inserting undoable block with hash: " + ByteUtils.formatHex(hashBytes)  + " at height " + height);
//
//            if (transactions == null) {
//                s.setBytes(2, txOutChanges);
//                s.setNull(3, Types.BINARY);
//            } else {
//                s.setNull(2, Types.BINARY);
//                s.setBytes(3, transactions);
//            }
//            s.executeUpdate();
//            s.close();
            try {
                putUpdateStoredBlock(storedBlock, true);
            } catch (SQLException e) {
                throw new BlockStoreException(e);
            }
        } catch (SQLException e) {
            if (!e.getSQLState().equals(POSTGRES_DUPLICATE_KEY_ERROR_CODE))
                throw new BlockStoreException(e);
        }

        cachedBlocks.put(blockHash, storedBlock);

        if (undoableBlock.getTransactions() == null) {
            return;
        }

        // insert transactions and outputs first
        try {
            int idx = 0;
            for (Transaction transaction : undoableBlock.getTransactions()) {
                long transactionId = ((((long)params.network().ordinal() << 26) + height) << 32) + idx;
                LocalTransaction lt = new LocalTransaction();

                lt.transactionId = transactionId;
                lt.version = (int) transaction.getVersion();
                lt.lockTime = (int) transaction.getLockTime();
                lt.hash = transaction.getTxId().getBytes();

                cachedTransactions.add(lt);
                cachedTransactionHashes.put(transaction.getTxId().toString(), transactionId);

                short outIdx = 0;
                for (TransactionOutput output: transaction.getOutputs()) {
                    LocalTransactionOutput lOutput = new LocalTransactionOutput();
                    lOutput.transactionId = transactionId;
                    lOutput.index = outIdx;
                    lOutput.value = output.getValue().value;
                    lOutput.coinbase = transaction.isCoinBase();
                    lOutput.scriptbytes = output.getScriptBytes();
                    lOutput.spend = false;

                    String transactionIdWithIndex = transactionId + "-" + outIdx;

                    cachedTransactionOutputs.put(transactionIdWithIndex, lOutput);
                    outIdx++;
                }

                short inIdx = 0;
                for (TransactionInput input:  transaction.getInputs()) {
                    LocalTransactionInput lInput = new LocalTransactionInput();
                    lInput.transactionId = transactionId;
                    lInput.index = inIdx;
                    lInput.scriptbytes = input.getScriptBytes();
                    lInput.witnessbytes = null;
                    if (input.isCoinBase()) {
                        lInput.spendTransactionId = -1L;
                        lInput.spendIndex = (short) -1;
                    } else {
                        if (input.getWitness() != null) {
                            lInput.witnessbytes = input.getWitness().serialize();
                        }
                        lInput.spendIndex = (short) input.getOutpoint().index();
                        // try find transaction
                        Long prevTransactionId = cachedTransactionHashes.get(input.getOutpoint().hash().toString());
                        if (prevTransactionId == null) {
                            prevTransactionId = getTransactionId(input.getOutpoint().hash().getBytes());
                            if (prevTransactionId == null) {
                                throw new BlockStoreException("Transaction output not found");
                            }
                            cachedLocalTransactionOutputId.add(new LocalTransactionOutputId(prevTransactionId, lInput.spendIndex));
                        } else {
                            String transactionSpendIdWithIndex = prevTransactionId + "-" + lInput.spendIndex;
                            LocalTransactionOutput ot = cachedTransactionOutputs.get(transactionSpendIdWithIndex);
                            if (ot == null) {
                                cachedLocalTransactionOutputId.add(new LocalTransactionOutputId(prevTransactionId, lInput.spendIndex));
                            } else {
                                ot.spend = true;
                            }
                        }
                        lInput.spendTransactionId = prevTransactionId;

                    }
                    cachedTransactionInputs.add(lInput);
                    inIdx++;
                }
                idx++;
            }

            if (height % 1000 == 0) {
                conn.get().setAutoCommit(false);
                PreparedStatement sTr = conn.get().prepareStatement(INSERT_TRANSACTION_SQL);
                PreparedStatement so = conn.get().prepareStatement(INSERT_TRANSACTION_OUTPUT_SQL);
                PreparedStatement si2 = conn.get().prepareStatement(INSERT_TRANSACTION_INPUT_SIMPLE_SQL);
                PreparedStatement si2u = conn.get().prepareStatement(UPDATE_TRANSACTION_AS_SPENDED_SQL);
                List<LocalTransaction> l1 = cachedTransactions.stream().sorted(LocalTransaction::compareTo).collect(Collectors.toList());
                boolean hasElements = false;
                for (int i = 0; i < l1.size(); i++) {
                    LocalTransaction lx = l1.get(0);
                    sTr.setLong(1, lx.transactionId);
                    sTr.setInt(2, lx.version);
                    sTr.setInt(3, lx.lockTime);
                    sTr.setBytes(4, lx.hash);
                    sTr.addBatch();
                    hasElements = true;
                    if (i % 2000 == 0) {
                        sTr.executeBatch();
                        hasElements = false;
                    }
                }
                if (hasElements)
                    sTr.executeBatch();
                hasElements = false;
                // inputs
                List<LocalTransactionInput> l2 = cachedTransactionInputs.stream().sorted(LocalTransactionInput::compareTo).collect(Collectors.toList());
                for (int i = 0; i < l2.size(); i++) {
                    LocalTransactionInput lx = l2.get(0);
                    si2.setLong(1, lx.transactionId);
                    si2.setLong(2, lx.spendTransactionId);
                    si2.setShort(3, lx.index);
                    si2.setShort(4, lx.spendIndex);
                    if (lx.scriptbytes == null) {
                        si2.setNull(5, Types.BINARY);
                    } else {
                        si2.setBytes(5, lx.scriptbytes);
                    }
                    if (lx.witnessbytes == null) {
                        si2.setNull(6, Types.BINARY);
                    } else {
                        si2.setBytes(6, lx.witnessbytes);
                    }
                    si2.addBatch();
                    hasElements = true;
                    if (i % 2000 == 0) {
                        si2.executeBatch();
                        hasElements = false;
                    }
                }
                if (hasElements)
                    si2.executeBatch();
                hasElements = false;
                // outputs
                List<LocalTransactionOutput> l3 = cachedTransactionOutputs.values().stream().sorted(LocalTransactionOutput::compareTo).collect(Collectors.toList());
                for (int i = 0; i < l3.size(); i++) {
                    LocalTransactionOutput lx = l3.get(0);
                    so.setLong(1, lx.transactionId);
                    so.setLong(2, lx.value);
                    so.setShort(3, lx.index);
                    so.setBoolean(4, lx.coinbase);
                    so.setBoolean(5, lx.spend);
                    if (lx.scriptbytes == null) {
                        so.setNull(6, Types.BINARY);
                    } else {
                        so.setBytes(6, lx.scriptbytes);
                    }
                    so.addBatch();
                    hasElements = true;
                    if (i % 2000 == 0) {
                        so.executeBatch();
                        hasElements = false;
                    }
                }
                if (hasElements)
                    so.executeBatch();
                hasElements = false;
                // update old transactions
                for (int i = 0; i < cachedLocalTransactionOutputId.size(); i++) {
                    LocalTransactionOutputId ido = cachedLocalTransactionOutputId.get(0);
                    si2u.setLong(1, ido.transactionId);
                    si2u.setShort(2, ido.index);
                    hasElements = true;
                    if (i % 2000 == 0) {
                        si2u.executeBatch();
                        hasElements = false;
                    }
                }
                if (hasElements)
                    si2u.executeBatch();
                conn.get().commit();
                conn.get().setAutoCommit(true);
                cachedTransactions.clear();
                cachedTransactionInputs.clear();
                cachedTransactionOutputs.clear();
                cachedLocalTransactionOutputId.clear();
            }
            // OLD STYLE CODE
//            int idx = 0;
//            for (Transaction transaction : undoableBlock.getTransactions()) {
//                long transactionId = ((((long)params.network().ordinal() << 26) + height) << 32) + idx;
//                sTr.setLong(1, transactionId);
//                sTr.setInt(2, (int) transaction.getVersion());
//                sTr.setInt(3, (int) transaction.getLockTime());
//                sTr.setBytes(4, transaction.getTxId().getBytes());
//                sTr.addBatch();
//
//                short outIdx = 0;
//                for (TransactionOutput output: transaction.getOutputs()) {
//                    Script script = getScript(output.getScriptBytes());
//                    so.setLong(1, transactionId);
//                    so.setShort(2, outIdx);
//                    so.setLong(3, output.getValue().value);
//                    so.setBytes(4, output.getScriptBytes());
//                    so.setBoolean(5, transaction.isCoinBase());
//                    so.addBatch();
//                    outIdx++;
//                }
//                cachedTransactionHashes.put(transaction.getTxId().toString(), transactionId);
//                idx++;
//            }
//            sTr.executeBatch();
//            so.executeBatch();
//            sTr.close();
//            so.close();
//
//            // inputs
//            idx = 0;
//            for (Transaction transaction: undoableBlock.getTransactions()) {
//                long transactionId = ((((long)params.network().ordinal() << 26) + height) << 32) + idx;
//                short inIdx = 0;
//                for (TransactionInput input:  transaction.getInputs()) {
//                    if (input.isCoinBase()) {
//                        si2.setLong(1, transactionId);
//                        si2.setLong(2, -1L);
//                        si2.setShort(3, inIdx);
//                        si2.setShort(4, (short) -1);
//                        si2.setBytes(5, input.getScriptBytes());
//                        si2.setNull(6, Types.BINARY);
//                        si2.addBatch();
//
//                    } else {
//                        Long prevTransactionId = cachedTransactionHashes.get(input.getOutpoint().hash().toString());
//                        if (prevTransactionId == null) {
//                            PreparedStatement si = conn.get().prepareStatement(INSERT_TRANSACTION_INPUT_SQL);
//
//                            si.setLong(1, transactionId);
//                            si.setShort(2, inIdx);
//                            si.setBytes(3, input.getScriptBytes());
//                            if (input.getWitness() != null) {
//                                si.setBytes(4, input.getWitness().serialize());
//                            } else {
//                                si.setNull(4, Types.BINARY);
//                            }
//                            if (input.isCoinBase()) {
//                                si.setNull(5, Types.BINARY);
//                            } else {
//                                si.setBytes(5, input.getOutpoint().hash().getBytes());
//                            }
//                            si.setShort(6, (short) input.getOutpoint().index());
//                            si.execute();
//
//                            si.close();
//                        } else {
//                            si2.setLong(1, transactionId);
//                            si2.setLong(2, prevTransactionId);
//                            si2.setShort(3, inIdx);
//                            si2.setShort(4, (short) input.getOutpoint().index());
//
//                            if (input.getScriptBytes() != null) {
//                                si2.setBytes(5, input.getScriptBytes());
//                            } else {
//                                si2.setNull(6, Types.BINARY);
//                            }
//                            if (input.getWitness() != null) {
//                                si2.setBytes(6, input.getWitness().serialize());
//                            } else {
//                                si2.setNull(6, Types.BINARY);
//                            }
//                            si2.addBatch();
//
//                            si2u.setLong(1, prevTransactionId);
//                            si2u.setLong(2, (short) input.getOutpoint().index());
//                            si2u.addBatch();
//                        }
//                    }
//                    inIdx++;
//                }
//                idx++;
//            }
//            si2.executeBatch();
//            si2u.executeBatch();
//            si2.close();
//            si2u.close();
        } catch (SQLException e) {
            if (!e.getSQLState().equals(POSTGRES_DUPLICATE_KEY_ERROR_CODE)) {
                log.error("Block " + height +  " : " + storedBlock.toString());
                try {
                    conn.get().rollback();
                } catch (SQLException ex) {
                   //
                }
                throw new BlockStoreException(e);
            }
        }
    }

    private void compactBlocks(int networkId) {
        PreparedStatement sc = null;
        try {
            sc = conn.get().prepareStatement(COMPACT_BLOCKS_SQL);

            sc.setShort(1, (short) networkId);
            sc.execute();
        } catch (SQLException e) {
           log.error("CompactBlocks", e);
        } finally {
            if (sc != null) {
                try {
                    sc.close();
                } catch (SQLException e) {
                    log.error("CompactBlocks", e);
                }
            }
        }
    }

    private Script getScript(byte[] scriptBytes) {
        try {
            return Script.parse(scriptBytes);
        } catch (Exception e) {
            return Script.parse(new byte[0]);
        }
    }
    private String getScriptAddress(Script script) {
        String address = "";
        try {
            if (script != null) {
                address = script.getToAddress(params.network(), true).toString();
            }
        } catch (Exception e) {
        }
        return address;
    }

    @Override
    public StoredBlock get(Sha256Hash hash) throws BlockStoreException {
        // Optimize for chain head
        if (chainHeadHash != null && chainHeadHash.equals(hash))
            return chainHeadBlock;
        if (verifiedChainHeadHash != null && verifiedChainHeadHash.equals(hash))
            return verifiedChainHeadBlock;

        StoredBlock storedBlockCached = cachedBlocks.get(hash);
        if (storedBlockCached != null) {
            return storedBlockCached;
        }


        maybeConnect();
        PreparedStatement s = null;
        try {
            s = conn.get().prepareStatement(SELECT_BLOCKS_SQL);
            // We skip the first 4 bytes because (on mainnet) the minimum target has 4 0-bytes
            byte[] hashBytes = hash.getBytes(); //new byte[28];
//            System.arraycopy(hash.getBytes(), 4, hashBytes, 0, 28);
            s.setBytes(1, hashBytes);
            ResultSet results = s.executeQuery();
            if (!results.next()) {
                return null;
            }
            // Parse it.

            if (!results.getBoolean(4))
                return null;

            BigInteger chainWork = new BigInteger(results.getBytes(1));
            int height = results.getInt(2);
            Block b = params.getDefaultSerializer().makeBlock(ByteBuffer.wrap(results.getBytes(3)));
            Block.verifyHeader(b);
            return new StoredBlock(b, chainWork, height);
        } catch (SQLException | VerificationException e) {
            // VerificationException: Should not be able to happen unless the database contains bad blocks.
            throw new BlockStoreException(e);
        } finally {
            if (s != null) {
                try {
                    s.close();
                } catch (SQLException e) {
                    throw new BlockStoreException("Failed to close PreparedStatement");
                }
            }
        }
    }

    @Override
    public StoredBlock getChainHead() throws BlockStoreException {
        return chainHeadBlock;
    }

    @Override
    public void setChainHead(StoredBlock chainHead) throws BlockStoreException {
        Sha256Hash hash = chainHead.getHeader().getHash();
        this.chainHeadHash = hash;
        this.chainHeadBlock = chainHead;
        maybeConnect();
        try {
            PreparedStatement s = conn.get().prepareStatement(UPDATE_SETTINGS_SQL);
            s.setString(2, CHAIN_HEAD_SETTING);
            s.setBytes(1, hash.getBytes());
            s.executeUpdate();
            s.close();
        } catch (SQLException ex) {
            throw new BlockStoreException(ex);
        }
    }

    @Override
    public void close() throws BlockStoreException {
        for (Connection conn : allConnections) {
            try {
                if (!conn.getAutoCommit()) {
                    conn.rollback();
                }
                conn.close();
                if (conn == this.conn.get()) {
                    this.conn.set(null);
                }
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
        }
        allConnections.clear();
    }

    @Override
    public StoredBlock getOnceUndoableStoredBlock(Sha256Hash hash) throws BlockStoreException {
        return get(hash);
    }

    @Override
    public StoredUndoableBlock getUndoBlock(Sha256Hash hash) throws BlockStoreException {
        maybeConnect();
        PreparedStatement s = null;
        try {
            s = conn.get().prepareStatement(SELECT_BLOCKS_DATA_SQL);
            // We skip the first 4 bytes because (on mainnet) the minimum target has 4 0-bytes

            byte[] hashBytes = hash.getBytes(); //new byte[28];
//            System.arraycopy(hash.getBytes(), 4, hashBytes, 0, 28);
            s.setBytes(1, hashBytes);
            ResultSet results = s.executeQuery();
            if (!results.next()) {
                return null;
            }
            // Parse it.
            byte[] txOutChanges = results.getBytes(1);
            byte[] transactions = results.getBytes(2);
            StoredUndoableBlock block;
            if (txOutChanges == null) {
                int numTxn = (int) ByteUtils.readUint32(transactions, 0);
                int offset = 4;
                List<Transaction> transactionList = new LinkedList<>();
                for (int i = 0; i < numTxn; i++) {
                    Transaction tx = params.getDefaultSerializer().makeTransaction(ByteBuffer.wrap(transactions)); // offset
                    transactionList.add(tx);
                    offset += tx.messageSize();
                }
                block = new StoredUndoableBlock(hash, transactionList);
            } else {
                TransactionOutputChanges outChangesObject =
                        new TransactionOutputChanges(new ByteArrayInputStream(txOutChanges));
                block = new StoredUndoableBlock(hash, outChangesObject);
            }
            return block;
        } catch (SQLException | IOException | ProtocolException | ClassCastException | NullPointerException e) {
            // IOException, ProtocolException, ClassCastException, NullPointerException: Corrupted database.
            throw new BlockStoreException(e);
        } finally {
            if (s != null) {
                try {
                    s.close();
                } catch (SQLException e) {
                    throw new BlockStoreException("Failed to close PreparedStatement");
                }
            }
        }
    }

    @Override
    public UTXO getTransactionOutput(Sha256Hash hash, long index) throws BlockStoreException {
        maybeConnect();
        PreparedStatement s = null;
        try {
            s = conn.get().prepareStatement(SELECT_OPENOUTPUTS_SQL);
            s.setBytes(1, hash.getBytes());
            // index is actually an unsigned int
            s.setInt(2, (int) index);
            ResultSet results = s.executeQuery();
            if (!results.next()) {
                return null;
            }
            // Parse it.
            int height = results.getInt(1);
            Coin value = Coin.valueOf(results.getLong(2));
            byte[] scriptBytes = results.getBytes(3);
            boolean coinbase = results.getBoolean(4);
            String address = results.getString(5);
            UTXO txout = new UTXO(hash,
                    index,
                    value,
                    height,
                    coinbase,
                    Script.parse(scriptBytes),
                    address);
            return txout;
        } catch (SQLException ex) {
            throw new BlockStoreException(ex);
        } finally {
            if (s != null) {
                try {
                    s.close();
                } catch (SQLException e) {
                    throw new BlockStoreException("Failed to close PreparedStatement");
                }
            }
        }
    }

    @Override
    public void addUnspentTransactionOutput(UTXO out) throws BlockStoreException {
//        maybeConnect();
//        PreparedStatement s = null;
//        try {
//            s = conn.get().prepareStatement(INSERT_OPENOUTPUTS_SQL);
//            s.setInt(1, out.getHeight());
//            s.setBytes(2, out.getHash().getBytes());
//            s.setInt(3, (int) out.getIndex());
//            s.setLong(4, out.getValue().value);
//            s.setBytes(5, out.getScript().getProgram());
//            s.setString(6, out.getAddress());
//            ScriptType scriptType = out.getScript().getScriptType();
//            s.setInt(7, scriptType != null ? scriptType.numericId() : 0);
//            s.setBoolean(8, out.isCoinbase());
//            s.executeUpdate();
//            s.close();
//        } catch (SQLException e) {
//            if (!(e.getSQLState().equals(POSTGRES_DUPLICATE_KEY_ERROR_CODE)))
//                throw new BlockStoreException(e);
//        } finally {
//            if (s != null) {
//                try {
//                    s.close();
//                } catch (SQLException e) {
//                    throw new BlockStoreException(e);
//                }
//            }
//        }
    }

    @Override
    public void removeUnspentTransactionOutput(UTXO out) throws BlockStoreException {
        maybeConnect();

        try {
            PreparedStatement s = conn.get().prepareStatement(UPDATE_TRANSACTION_OUTPUT_AS_SPEND_SQL);
            s.setBytes(1, out.getHash().getBytes()); // TODO
            // index is actually an unsigned int
            s.setShort(2, (short)out.getIndex());
            s.executeUpdate();
            s.close();
        } catch (SQLException e) {
            throw new BlockStoreException(e);
        }
    }

    @Override
    public boolean hasUnspentOutputs(Sha256Hash hash, int numOutputs) throws BlockStoreException {
        maybeConnect();
        PreparedStatement s = null;
        try {
            s = conn.get().prepareStatement(SELECT_EXISTS_OPEN_TRANSACTION);
            s.setBytes(1, hash.getBytes());
            ResultSet results = s.executeQuery();
            if (!results.next()) {
                throw new BlockStoreException("Got no results from a COUNT(*) query");
            }
            int count = results.getInt(1);
            return count != 0;
        } catch (SQLException ex) {
            throw new BlockStoreException(ex);
        } finally {
            if (s != null) {
                try {
                    s.close();
                } catch (SQLException e) {
                    throw new BlockStoreException("Failed to close PreparedStatement");
                }
            }
        }
    }

    @Override
    public StoredBlock getVerifiedChainHead() throws BlockStoreException {
        return verifiedChainHeadBlock;
    }

    @Override
    public void setVerifiedChainHead(StoredBlock chainHead) throws BlockStoreException {
        Sha256Hash hash = chainHead.getHeader().getHash();
        this.verifiedChainHeadHash = hash;
        this.verifiedChainHeadBlock = chainHead;
        maybeConnect();
        try {
            PreparedStatement s = conn.get().prepareStatement(UPDATE_SETTINGS_SQL);
            s.setString(2, VERIFIED_CHAIN_HEAD_SETTING);
            s.setBytes(1, hash.getBytes());
            s.executeUpdate();
            s.close();
        } catch (SQLException ex) {
            throw new BlockStoreException(ex);
        }
        if (this.chainHeadBlock.getHeight() < chainHead.getHeight())
            setChainHead(chainHead);
    }

    @Override
    public void beginDatabaseBatchWrite() throws BlockStoreException {
//        maybeConnect();
//        try {
//            conn.get().setAutoCommit(false);
//        } catch (SQLException e) {
//            throw new BlockStoreException(e);
//        }
    }

    @Override
    public void commitDatabaseBatchWrite() throws BlockStoreException {
//        maybeConnect();
//        try {
//            conn.get().commit();
//            conn.get().setAutoCommit(true);
//        } catch (SQLException e) {
//            throw new BlockStoreException(e);
//        }
    }

    @Override
    public void abortDatabaseBatchWrite() throws BlockStoreException {
//        maybeConnect();
//        try {
//            if (!conn.get().getAutoCommit()) {
//                conn.get().rollback();
//                conn.get().setAutoCommit(true);
//            } else {
//                log.warn("Warning: Rollback attempt without transaction");
//            }
//        } catch (SQLException e) {
//            throw new BlockStoreException(e);
//        }
    }


    public void watchForTempTables() {
        for (int i = 0; i < 1000; i++) {
            try {
                log.info("Processing...");
                PreparedStatement pStage0 = conn.get().prepareStatement(INSERT_TRANSACTION_TMP_TABLE_STAGE0);
                int rows0 = pStage0.executeUpdate();
                pStage0.close();
                PreparedStatement pStage1 = conn.get().prepareStatement(INSERT_TRANSACTION_TMP_TABLE_STAGE1);
                int rows1 = pStage1.executeUpdate();
                pStage1.close();
                PreparedStatement pStage2 = conn.get().prepareStatement(INSERT_TRANSACTION_TMP_TABLE_STAGE2);
                int rows2 = pStage2.executeUpdate();
                pStage2.close();
                log.info("watchForTempTables => " + rows0 + " " + rows1 + " " + rows2);
                for (int j = 0; j < 4; j++) {
                    log.info("Waiting...");
                    Thread.sleep(60000); // 1 min
                }
            } catch (SQLException e) {
                log.warn("Error watchForTempTables", e);
                throw new RuntimeException(e);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }
    }


//
//    public void savePrivateKey(String address, byte[] pk, boolean correct, boolean compressed, String base) throws BlockStoreException {
//        maybeConnect();
//        try {
//            PreparedStatement s = conn.get().prepareStatement(INSERT_PRIVATEKEYS_SQL);
//            s.setString(1, address);
//            s.setBytes(2, pk);
//            s.setBoolean(3, correct);
//            s.setBoolean(4, compressed);
//            s.setString(5,base);
//            s.executeUpdate();
//            s.close();
//        } catch (SQLException ex) {
//            throw new BlockStoreException(ex);
//        }
//    }
//
//    public void saveParamR(byte[] r, byte[] n) throws BlockStoreException {
//        maybeConnect();
//        try {
//            PreparedStatement s = conn.get().prepareStatement(INSERT_PARAMSR_SQL);
//            s.setBytes(1, r);
//            s.setBytes(2, n);
//            s.executeUpdate();
//            s.close();
//        } catch (SQLException ex) {
//            throw new BlockStoreException(ex);
//        }
//    }
//
//
//
//    public List<AddressPairR> selectAllPairR() throws BlockStoreException {
//        maybeConnect();
//        PreparedStatement s = null;
//        List<AddressPairR> result = new ArrayList<>();
//        try {
//            s = conn.get().prepareStatement(SELECT_ALL_PAIR_R);
//
//            ResultSet results = s.executeQuery();
//            while (results.next()) {
//                result.add(new AddressPairR(results));
//            }
//            results.close();
//
//        } catch (SQLException ex) {
//            throw new BlockStoreException(ex);
//        } finally {
//            if (s != null) {
//                try {
//                    s.close();
//                } catch (SQLException e) {
//                    throw new BlockStoreException("Failed to close PreparedStatement");
//                }
//            }
//        }
//        return result;
//    }
//
//
//    public List<RowPairR> selectPairR(long transacionId, int index) throws BlockStoreException {
//        maybeConnect();
//        PreparedStatement s = null;
//        List<RowPairR> result = new ArrayList<>();
//        try {
//            s = conn.get().prepareStatement(SELECT_DETIAL_PAIR_R);
//            s.setLong(1, transacionId);
//            s.setInt(2, index);
//
//            ResultSet results = s.executeQuery();
//            while (results.next()) {
//                result.add(new RowPairR(results));
//            }
//            results.close();
//
//        } catch (SQLException ex) {
//            throw new BlockStoreException(ex);
//        } finally {
//            if (s != null) {
//                try {
//                    s.close();
//                } catch (SQLException e) {
//                    throw new BlockStoreException("Failed to close PreparedStatement");
//                }
//            }
//        }
//        return result;
//    }


    public static class LocalTransaction implements Comparable<LocalTransaction> {
        Long transactionId;
        Integer version;
        Integer lockTime;
        byte[] hash;

        @Override
        public int compareTo(LocalTransaction o) {
            return Long.compare(this.transactionId, o.transactionId);
        }
    }

    public static class LocalTransactionInput implements Comparable<LocalTransactionInput>{
        Long transactionId;
        Short index;
        Long spendTransactionId;
        Short spendIndex;
        byte[] scriptbytes;
        byte[] witnessbytes;

        @Override
        public int compareTo(LocalTransactionInput o) {
            int c = Long.compare(this.transactionId, o.transactionId);
            if (c == 0) {
                return Long.compare(this.index, o.index);
            } else {
                return c;
            }
        }
    }

    public static class LocalTransactionOutputId {

        public LocalTransactionOutputId(Long transactionId, Short index) {
            this.transactionId = transactionId;
            this.index = index;
        }

        Long transactionId;
        Short index;
    }

    public static class LocalTransactionOutput implements Comparable<LocalTransactionOutput> {
        Long transactionId;
        Short index;
        Long value;
        boolean coinbase;
        boolean spend;
        byte[] scriptbytes;

        @Override
        public int compareTo(LocalTransactionOutput o) {
            int c = Long.compare(this.transactionId, o.transactionId);
            if (c == 0) {
                return Long.compare(this.index, o.index);
            } else {
                return c;
            }
        }
    }
}
