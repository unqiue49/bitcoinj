SET ROLE myadmin;

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
SELECT ($1 & 65535)::int4;
$fnc$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_transaction_id(int8) RETURNS int8 AS $fnc$
SELECT $1 & 9223372036854710272;
$fnc$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_block_first_transaction_index(int2, int4) RETURNS int8 AS $fnc$ -- netId, block
SELECT ((($1::int8) << 26) + $2::int8) << 32;
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

CREATE OR REPLACE FUNCTION create_transactions_partition(in heigth int4, in net_id int2) returns boolean as
$BODY$
DECLARE
 p1 int8;
 p2 int8;
 p3 int8;
 p4 int8;
 prefix varchar;
 net_suffix varchar;
 main_partition varchar;
 sub_parition varchar;
 sub_sub_parition varchar;
 v1 int4;
 v2 int4;
 prev_size int8;
 prev_part int8;
 calc int4;
 step int4;
 command varchar;
begin
	if (heigth = 0) then
		p1 := get_block_first_transaction_index(net_id,0);
		p2 := get_block_first_transaction_index(net_id,150000) - 1;
		prefix := '0_150k';
	elsif (heigth < 150000) then
		return false;
    else -- step by 10k
		if (mod(heigth, 10000) = 0) then
			p1 := get_block_first_transaction_index(net_id,heigth);
			p2 := get_block_first_transaction_index(net_id,heigth + 10000) - 1;
			v1 := (heigth/1000)::int4;
			v2 := v1+10;
			prefix := v1||'k_'||v2||'k';
        else
			return false;
        end if;
    end if;

    select suffix into net_suffix from nets where id = net_id;

    main_partition := 'transactions_'||net_suffix;
	sub_parition := main_partition||'_'||prefix;

    with base as (
        SELECT inhrelid oidd, pg_total_relation_size(inhrelid::regclass) val
        FROM   pg_catalog.pg_inherits
        WHERE  inhparent = main_partition::regclass
    order by inhrelid desc LIMIT 1
        ), subs as (
    SELECT avg(pg_total_relation_size(inhrelid::regclass))::int8 val, count(1) parts
    FROM   pg_catalog.pg_inherits
        join   base on oidd = inhparent
        )
    select coalesce((select val from subs), val), coalesce((select parts from subs),0) + 1 into prev_size, prev_part
    from base;

    command := 'CREATE TABLE '||sub_parition||' PARTITION OF '||main_partition||' FOR VALUES FROM ('||p1||') TO ('||p2||')';

	-- create subpartitions based on previous partition size
	if (mod(heigth, 10000) = 0) and (prev_size > 850000000 OR heigth > 170000) then
		calc := ceil((prev_size * prev_part)/750000000);

        if (calc < 2) then
            calc := 2;
        end if;
		step := (10000 / calc)::int4;
		command := command || 'partition by range(id)';
        execute command;

        FOR i IN 1..calc LOOP
			sub_sub_parition := sub_parition||'_'||i;
            raise notice 'x % % %', heigth + ((i-1) * step), (heigth + (i * step) ) - 1, step;

			p3 := get_block_first_transaction_index(net_id,heigth + ((i-1) * step));
			p4 := get_block_first_transaction_index(net_id,heigth + (i * step) ) - 1;
			if i = calc then
				p4 := p2;
            end if;
				raise notice 'xx % % %', i, p3, p4;
			command := 'CREATE TABLE '||sub_sub_parition||' PARTITION OF '||sub_parition||' FOR VALUES FROM ('||p3||') TO ('||p4||');';
			raise notice 'SQL: %', command;
            execute command;
        END LOOP;
    else
        command := command || ';';
        execute command;
    end if;
    RETURN true;
END;
$BODY$
LANGUAGE plpgsql VOLATILE COST 100;


CREATE OR REPLACE FUNCTION create_transaction_outputs_partition(in heigth int4, in net_id int2) returns boolean as
$BODY$
DECLARE
 p1 int8;
 p2 int8;
 p3 int8;
 p4 int8;
 prefix varchar;
 net_suffix varchar;
 main_partition varchar;
 sub_parition varchar;
 sub_sub_parition varchar;
 v1 int4;
 v2 int4;
 prev_size int8;
 prev_part int8;
 calc int4;
 step int4;
 command varchar;
begin
	if (heigth = 0) then
		p1 := get_block_first_transaction_index(net_id,0);
		p2 := get_block_first_transaction_index(net_id,200000) - 1;
		prefix := '0_200k';
	    prev_part := 0;
	elsif (heigth < 200000) then
		return false;
    elsif (heigth < 300000) then
		if (mod(heigth, 20000) = 0) then
			p1 := get_block_first_transaction_index(net_id,heigth);
			p2 := get_block_first_transaction_index(net_id,heigth + 20000) - 1;
			v1 := (heigth/1000)::int4;
			v2 := v1+20;
			prefix := v1||'k_'||v2||'k';
			prev_part := 0;
        else
			return false;
        end if;
    elsif (heigth < 300000) then
		if (mod(heigth, 10000) = 0) then
			p1 := get_block_first_transaction_index(net_id,heigth);
			p2 := get_block_first_transaction_index(net_id,heigth + 10000) - 1;
			v1 := (heigth/1000)::int4;
			v2 := v1+10;
			prefix := v1||'k_'||v2||'k';
			prev_part := 0;
        else
			return false;
        end if;
    else -- step by 10k
		if (mod(heigth, 10000) = 0) then
			p1 := get_block_first_transaction_index(net_id,heigth);
			p2 := get_block_first_transaction_index(net_id,heigth + 10000) - 1;
			v1 := (heigth/1000)::int4;
			v2 := v1+10;
			prefix := v1||'k_'||v2||'k';
			if (heigth < 360000) then
		    	prev_part := 2;
			elsif (heigth < 440000) then
				prev_part := 4;
			elsif (heigth < 600000) then
				prev_part := 6;
			elsif (heigth < 700000) then
				prev_part := 8;
            else
				prev_part := 10;
            end if;
        else
			return false;
        end if;
    end if;

    select suffix into net_suffix from nets where id = net_id;

    main_partition := 'transaction_outputs_spend_'||net_suffix;
	sub_parition := main_partition||'_'||prefix;


	command := 'CREATE TABLE '||sub_parition||' PARTITION OF '||main_partition||' FOR VALUES FROM ('||p1||') TO ('||p2||')';

    if (prev_part > 0) then
        command := command || 'partition by range(input_id)';
        raise notice 'SQL: %', command;
        execute command;
        step := ceil(10000 / prev_part);
        FOR i IN 1..prev_part LOOP
            sub_sub_parition := sub_parition||'_'||i;
            raise notice 'x % % %', heigth + ((i-1) * step), (heigth + (i * step) ) - 1, step;

            p3 := get_block_first_transaction_index(net_id,heigth + ((i-1) * step));
            p4 := get_block_first_transaction_index(net_id,heigth + (i * step) ) - 1;
            if i = prev_part then
                p4 := p2;
            end if;
            raise notice 'xx % % %', i, p3, p4;
            command := 'CREATE TABLE '||sub_sub_parition||' PARTITION OF '||sub_parition||' FOR VALUES FROM ('||p3||') TO ('||p4||');';
            raise notice 'SQL: %', command;
            execute command;
        END LOOP;
    else
        raise notice 'SQL: %', command;
        execute command;
    end if;

RETURN true;
END;
$BODY$
LANGUAGE plpgsql VOLATILE COST 100;

-- secret must be 32 bytes length
CREATE OR REPLACE FUNCTION btc_generate_key(secret bytea, compressed bool = true) RETURNS bytea
AS $$
	import os
	from pysecp256k1 import tagged_sha256, ec_pubkey_create, ec_pubkey_serialize

	pubkey = ec_pubkey_create(secret)

	return ec_pubkey_serialize(pubkey, compressed)
$$
LANGUAGE 'plpython3u';