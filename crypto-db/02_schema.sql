CREATE TABLE settings
(
    name  character varying(32) NOT NULL,
    value bytea,
    CONSTRAINT setting_pk PRIMARY KEY (name)
);

create table nets
(
    id   smallserial primary key,
    protocol varchar(12),
    code     varchar(12),
    name     varchar(48),
    suffix   varchar(12),
    test     boolean
);

CREATE TABLE blocks
(
    height      int4    NOT null,
    net_id      int2    not null,
    hash        bytea   NOT null,
    chainwork   bytea   NOT NULL,
    header      bytea   NOT NULL,
    wasundoable boolean NOT NULL,
    CONSTRAINT blocks_pk PRIMARY KEY (height, net_id)
) partition by list (net_id);

CREATE UNIQUE INDEX blocks_hash ON blocks USING btree (hash, net_id);

CREATE TABLE blocks_btc PARTITION OF blocks FOR values IN (1);

CREATE TABLE blocks_btc_test PARTITION OF blocks FOR VALUES IN (2);

CREATE TABLE blocks_btc_sig PARTITION OF blocks FOR VALUES IN (3);

CREATE TABLE blocks_btc_reg PARTITION OF blocks FOR values IN (4);


CREATE TABLE blocks_data
(
    hash         bytea NOT null,
    txoutchanges bytea,
    transactions bytea,
    CONSTRAINT blocks_data_pk PRIMARY KEY (hash)
);


insert into nets(protocol, code, name, suffix, test) values ('bitcoin','MAINNET','org.bitcoin.production', 'btc', false);
insert into nets(protocol, code, name, suffix, test) values ('bitcoin','TESTNET','org.bitcoin.test', 'btc_test', true);
insert into nets(protocol, code, name, suffix, test) values ('bitcoin','SIGNET','org.bitcoin.signet', 'btc_sig', true);
insert into nets(protocol, code, name, suffix, test) values ('bitcoin','REGTEST','org.bitcoin.regtest', 'btc_reg', true);

CREATE TYPE transaction_input AS (
    prevId int8,
    index int2,
    script bytea,
    witness bytea
);

CREATE TYPE transaction_output AS (
    value int8,
    index int2,
    coinbase boolean,
    script bytea
);

create table transactions
(
    id int8  not null, -- block_id <<32 + index ?  block_id int4 NOT null, -- future set block id ? ,index int4 not null,
    version        int4  NOT null,
    locktime       int4  NOT null,
    hash           bytea NOT null,
    inputs         transaction_input[] COMPRESSION pglz NOT null,
    outputs        transaction_output[] COMPRESSION pglz NOT null,
    CONSTRAINT transactions_pkey PRIMARY KEY (id)
) partition by range (id);

-- Main partitions with defaults
CREATE TABLE transactions_btc PARTITION OF transactions
    FOR VALUES FROM (288230376151711744) TO (576460752303423487) partition by range(id);
CREATE TABLE transactions_btc_default PARTITION OF transactions_btc DEFAULT;

CREATE TABLE transactions_btc_test PARTITION OF transactions
    FOR VALUES FROM (576460752303423488) TO (864691128455135231) partition by range(id);

CREATE TABLE transactions_btc_sig PARTITION OF transactions
    FOR VALUES FROM (864691128455135232) TO (1152921504606846975) partition by range(id);
CREATE TABLE transactions_btc_sig_default PARTITION OF transactions_btc_sig DEFAULT;

CREATE TABLE transactions_btc_reg PARTITION OF transactions
    FOR VALUES FROM (1152921504606846976) TO (1441151880758558719) partition by range(id);
CREATE TABLE transactions_btc_reg_default PARTITION OF transactions_btc_reg DEFAULT;

create table transaction_outputs_open
(
    output_id int8 not null primary key
) partition by range (output_id);

CREATE TABLE transaction_outputs_open_btc PARTITION OF transaction_outputs_open
    FOR VALUES FROM (288230376151711744) TO (576460752303423487) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_default PARTITION OF transaction_outputs_open_btc DEFAULT;

CREATE TABLE transaction_outputs_open_btc_test PARTITION OF transaction_outputs_open
    FOR VALUES FROM (576460752303423488) TO (864691128455135231) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_test_default PARTITION OF transaction_outputs_open_btc_test DEFAULT;

CREATE TABLE transaction_outputs_open_btc_sig PARTITION OF transaction_outputs_open
    FOR VALUES FROM (864691128455135232) TO (1152921504606846975) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_sig_default PARTITION OF transaction_outputs_open_btc_sig DEFAULT;

CREATE TABLE transaction_outputs_open_btc_reg PARTITION OF transaction_outputs_open
    FOR VALUES FROM (1152921504606846976) TO (1441151880758558719) partition by range(output_id);
CREATE TABLE transaction_outputs_open_btc_reg_default PARTITION OF transaction_outputs_open_btc_reg DEFAULT;

create table transaction_outputs_spend
(
    input_id int8 not null primary key,
    output_id int8 not null
) partition by range (input_id);

CREATE TABLE transaction_outputs_spend_btc PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (288230376151711744) TO (576460752303423487) partition by range(input_id);
CREATE TABLE transaction_outputs_spend_default PARTITION OF transaction_outputs_spend_btc DEFAULT;

CREATE TABLE transaction_outputs_spend_btc_test PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (576460752303423488) TO (864691128455135231) partition by range(input_id);
CREATE TABLE transaction_outputs_spend_test_default PARTITION OF transaction_outputs_spend_btc_test DEFAULT;

CREATE TABLE transaction_outputs_spend_btc_sig PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (864691128455135232) TO (1152921504606846975) partition by range(input_id);
CREATE TABLE transaction_outputs_spend_sig_default PARTITION OF transaction_outputs_spend_btc_sig DEFAULT;

CREATE TABLE transaction_outputs_spend_btc_reg PARTITION OF transaction_outputs_spend
    FOR VALUES FROM (1152921504606846976) TO (1441151880758558719) partition by range(input_id);
CREATE TABLE transaction_outputs_spend_reg_default PARTITION OF transaction_outputs_spend_btc_reg DEFAULT;