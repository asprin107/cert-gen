#!/bin/bash

#
KEY_ALGORITHM=ecdsa
KEY_BIT=256


# default root ca certificate info (self-signed)

ROOT_CERT_FILE=tls-ca-cert.crt
ROOT_KEY_FILE=tls-ca-cert.key
ROOT_CSR_FILE=tls-ca-cert.csr
ROOT_CSR_C="/C=KR"
ROOT_CSR_ST="/ST=Seoul"
ROOT_CSR_L="/L=Yeongdeungpo"
ROOT_CSR_O="/O=BERITH enterprise"
ROOT_CSR_CN="/CN=TLS CA server"
ROOT_EXT_FILE=v3-root.ext

# default client certificate info (ca signed)
CLIENT_CERT_FILE=tls-cert.crt
CLIENT_KEY_FILE=tls-cert.key
CLIENT_CSR_FILE=tls-cert.csr
CLIENT_CSR_C="/C=KR"
CLIENT_CSR_ST="/ST=Seoul"
#CLIENT_CSR_L="/L=Yeongdeungpo"
CLIENT_CSR_O="/O=BERITH enterprise"
CLIENT_CSR_CN="/CN=TLS CA client"
CLIENT_EXT_FILE=v3-client.ext

# default day is 15 years
CERT_DAYS=5475


# This command file locate. (absolute)
CURR_DIR=$(cd "$(dirname $0)" && pwd)

ROOT_CERT_HOME=$CURR_DIR/root/
CLIENT_CERT_HOME=$CURR_DIR/client/


function generateRootCert() {
  mkdir $ROOT_CERT_HOME
  echo "Generate ROOT key-pair"
  ssh-keygen -t $KEY_ALGORITHM -b $KEY_BIT -N '' -f $ROOT_CERT_HOME$ROOT_KEY_FILE
  # ssh-keygen -t ecdsa -b 256 -N '' -f private.key

  echo "Create ROOT CSR"
  openssl req -new -key $ROOT_CERT_HOME$ROOT_KEY_FILE -out $ROOT_CERT_HOME$ROOT_CSR_FILE -subj "$ROOT_CSR_C$ROOT_CSR_ST$ROOT_CSR_L$ROOT_CSR_O$ROOT_CSR_CN"
  # openssl req -new -key private.key -out cert.csr -subj "/C=KR/ST=Seoul/O=Berith/CN=Berith"

  echo "Create and sign ROOT cert"
  openssl x509 -req -days $CERT_DAYS -in $ROOT_CERT_HOME$ROOT_CSR_FILE -signkey $ROOT_CERT_HOME$ROOT_KEY_FILE -out $ROOT_CERT_HOME$ROOT_CERT_FILE -extfile $ROOT_EXT_FILE
  # openssl x509 -req -days 365 -in cert.csr -signkey private.key -out cert.crt -extfile v3.ext
}

function generateClientCert() {
echo "PARAM : $1"
  if [[ $1 != "" ]]; then
    CLIENT_CERT_HOME=$CURR_DIR/$1/
  fi
echo "HOME : $CLIENT_CERT_HOME"
  mkdir -p $CLIENT_CERT_HOME
  echo "Generate CLIENT key-pair"
  ssh-keygen -t $KEY_ALGORITHM -b $KEY_BIT -N '' -f $CLIENT_CERT_HOME$CLIENT_KEY_FILE
  # ssh-keygen -t ecdsa -b 256 -N '' -f private.key

  echo "Create CLIENT CSR"
  openssl req -new -key $CLIENT_CERT_HOME$CLIENT_KEY_FILE -out $CLIENT_CERT_HOME$CLIENT_CSR_FILE -subj "$CLIENT_CSR_C$CLIENT_CSR_ST$CLIENT_CSR_L$CLIENT_CSR_O$CLIENT_CSR_CN"
  # openssl req -new -key private.key -out cert.csr -subj "/C=KR/ST=Seoul/O=Berith/CN=Berith"

  echo "Create and sign CLIENT cert"
  openssl x509 -req -days $CERT_DAYS -in $CLIENT_CERT_HOME$CLIENT_CSR_FILE -out $CLIENT_CERT_HOME$CLIENT_CERT_FILE -CA $ROOT_CERT_HOME$ROOT_CERT_FILE -CAkey $ROOT_CERT_HOME$ROOT_KEY_FILE -CAcreateserial -extfile $CLIENT_EXT_FILE
  # openssl x509 -req -in ./client/cert.csr -out ./client/tla-ca-cert.crt -signkey ./client/tls-ca-cert.key -CA ./root/tls-ca-cert.crt -CAkey ./root/tls-ca-cert.key -CAcreateserial -days 365 -extfile v3-client.ext
}

generateRootCert
generateClientCert client1
generateClientCert client2
generateClientCert client3
generateClientCert client4

exit 0
