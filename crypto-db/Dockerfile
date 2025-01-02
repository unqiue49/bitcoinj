FROM postgres:17

RUN echo "============ INSTALLING PYTHON =============="

RUN apt update && apt install build-essential libtool g++ automake git python3 python3-pip postgresql-plpython3-${PG_MAJOR} -y

RUN apt install python3-base58 python3-ecdsa libssl-dev python3-bitcoinlib -y

RUN git clone https://github.com/bitcoin-core/secp256k1.git

RUN cd secp256k1/ && ./autogen.sh && ./configure --enable-module-recovery

RUN cd secp256k1/ && make && make install && ldconfig

RUN ldd /usr/local/lib/libsecp256k1.so.5

RUN pip3 install python-secp256k1 --break-system-packages