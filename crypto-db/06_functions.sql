CREATE OR REPLACE FUNCTION read_le_int4(ibytes bytea, istart int4) RETURNS int4 AS
$BODY$
begin
return (get_byte(ibytes, istart + 3) << 24) + (get_byte(ibytes, istart + 2) << 16) + (get_byte(ibytes, istart + 1) << 8) + get_byte(ibytes, istart);
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
-- python is slower in read_le_int4

CREATE OR REPLACE FUNCTION read_int8(ibytes bytea, istart int4) RETURNS int8 AS
$BODY$
begin
return (get_byte(ibytes, istart)::int8 << 56) + (get_byte(ibytes, istart + 1)::int8 << 48) +
       (get_byte(ibytes, istart + 2)::int8 << 40) + (get_byte(ibytes, istart + 3)::int8 << 32) +
       (get_byte(ibytes, istart + 4) << 24) + (get_byte(ibytes, istart + 5) << 16) +
       (get_byte(ibytes, istart + 6) << 8) + (get_byte(ibytes, istart + 7));
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE OR REPLACE FUNCTION read_be_int8(ibytes bytea, istart int4)
RETURNS int8
AS $$
    return int.from_bytes((ibytes)[istart:istart+8], "big", signed="True");
$$
LANGUAGE 'plpython3u';

CREATE OR REPLACE FUNCTION read_be_bytea(val int8) RETURNS bytea
AS $$
    return (val).to_bytes(8, byteorder='big', signed="True");
$$
LANGUAGE 'plpython3u';

CREATE OR REPLACE FUNCTION read_be_bytea(part1 int8, part2 int8, part3 int8, part4 int8) RETURNS bytea
AS $$
    return (part1).to_bytes(8, byteorder='big', signed="True") + (part2).to_bytes(8, byteorder='big', signed="True") + (part3).to_bytes(8, byteorder='big', signed="True") + (part4).to_bytes(8, byteorder='big', signed="True");
$$
LANGUAGE 'plpython3u';

CREATE OR REPLACE FUNCTION reverse(val bytea)
RETURNS bytea
AS $$
    return (val)[::-1];
$$ LANGUAGE 'plpython3u';

CREATE OR REPLACE FUNCTION get_transaction_block_id(int8) RETURNS int4 AS $fnc$
SELECT ($1 >> 32)::int4 & 2080374783
$fnc$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_transaction_net_id(int8) RETURNS int2 AS $fnc$
SELECT ($1 >> 58)::int2
$fnc$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_transaction_index(int8) RETURNS int4 AS $fnc$
SELECT (($1 >> 16) & 32767)::int4
$fnc$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION read_header_block(in iheader bytea, out block_version int4, out prev_block_hash bytea, out merkle_root bytea, out block_time timestamp, out difficulty_target int4, out nonce int4) returns SETOF RECORD as
$BODY$
DECLARE
v_spend_transaction_id int8;
begin
	block_version := read_le_int4(iheader, 0);
	prev_block_hash := reverse(substring(iheader, 5, 32));
	merkle_root := reverse(substring(iheader, 37, 32));
	block_time := to_timestamp(read_le_int4(iheader, 68));
	difficulty_target := read_le_int4(iheader, 72);
	nonce := read_le_int4(iheader, 76);

	RETURN NEXT;
  RETURN;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
  COST 100;



-- CREATE OR REPLACE FUNCTION compact_blocks(inet_id int2) RETURNS BOOLEAN AS
-- $BODY$
-- DECLARE
-- v_block_checkpoint int4;
-- begin
-- select max(height)-5000 into v_block_checkpoint from blocks where net_id = inet_id;
--
-- delete from blocks_data d where exists (select 1 from blocks b where b.hash = d.hash and b.net_id = inet_id and b.height < v_block_checkpoint);
--
-- update blocks set wasundoable = false where net_id = inet_id and height < v_block_checkpoint;
--
-- REINDEX TABLE blocks;
-- 	REINDEX TABLE blocks_data;
--
-- RETURN TRUE;
-- END;
-- $BODY$
-- LANGUAGE plpgsql VOLATILE
--   COST 100;


-- CREATE OR REPLACE FUNCTION connect_transaction(itransaction_id int8, iindex int2, iscriptbytes bytea, iwitnessbytes bytea, ispend_hash bytea, ispend_index int2) RETURNS BOOLEAN AS
-- $BODY$
-- DECLARE
-- v_spend_transaction_id int8;
-- begin
-- 	if ispend_hash is null then
-- 		v_spend_transaction_id := -1;
-- else
-- select transaction_id into v_spend_transaction_id from transactions where hash = ispend_hash;
-- update transaction_outputs set spend = true where transaction_id = v_spend_transaction_id and "index" = ispend_index and spend = false;
-- end if;
--
-- insert into transaction_inputs(transaction_id, "index", spend_transaction_id, spend_index, scriptbytes, witnessbytes)
-- values (itransaction_id, iindex, v_spend_transaction_id, ispend_index, iscriptbytes, iwitnessbytes);
--
-- RETURN TRUE;
-- END;
-- $BODY$
-- LANGUAGE plpgsql VOLATILE
--   COST 100;