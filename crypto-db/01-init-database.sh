#!/bin/bash
set -e

apt update && apt install python3 python3-pip postgresql-plpython3-${PG_MAJOR} -y

apt install python3-base58 python3-ecdsa libssl-dev python3-bitcoinlib -y

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $USERDB with encrypted password '$USERDB_PASSWORD';
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $USERDB;

    ALTER SCHEMA public OWNER TO $USERDB;

    CREATE EXTENSION pgcrypto;
    CREATE EXTENSION intarray;
    CREATE EXTENSION IF NOT EXISTS plpython3u;

    CREATE ROLE myadmin WITH SUPERUSER NOINHERIT;
    GRANT myadmin TO $USERDB;
EOSQL