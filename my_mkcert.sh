#!/bin/sh

# Here you must have your own CA key and certificate (and it must called myCA)
CERTS_PATH="$HOME/certs"

# Save path for generated certificates
CERTS_SITES="$CERTS_PATH/sites"

if [ "$#" -ne 1 ]
then
  echo "Generate a CA and a self signed certificate"
  echo "Usage: Must supply a domain"
  exit 1
fi

DOMAIN=$1

if [ ! -d "$CERTS_PATH" ]
then
  mkdir -p "$CERTS_PATH"
fi


if [ ! -d "$CERTS_SITES" ]
then
  mkdir -p "$CERTS_SITES"
fi


if [ ! -f "$CERTS_PATH/myCA.key" ] || [ ! -f "$CERTS_PATH/myCA.pem" ]
then
  echo "CA not found"
  echo "Generate the private key to become a local CA"
  echo "You should put a password to avoid someone generate root certificate for you and save it"
  openssl genrsa -des3 -out  "$CERTS_PATH/myCA.key" 2048
  echo "Generate a root certificate"
  echo "Maybe only fill the Common Name that you’ll recognize as your root certificate"
  openssl req -x509 -new -nodes -key "$CERTS_PATH/myCA.key" -sha256 -days 1825 -out "$CERTS_PATH/myCA.pem"

    # check if trust program is installed
    if command -v trust > /dev/null 2>&1
    then 
        echo "Install the CA in the system trust store"
        trust anchor --store "$CERTS_PATH/myCA.pem"
    else
        # echo red text bold
        printf '\033[01;31mtrust program is not installed. You must add the CA in the system trust store\033[00m\n'
        printf 'You can use certutil or add it manually\n'
        exit 1
    fi
fi


if [ -f "$CERTS_SITES/$DOMAIN.key" ]
then
  printf '\033[01;31mCertificate for domain %s already exists\033[00m\n' "$DOMAIN"
  exit 1
fi

printf '\033[01;32mGenerating certificate for domain %s\033[00m\n' "$DOMAIN"
openssl genrsa -out "$CERTS_SITES/$DOMAIN.key" 2048
openssl req -new -key "$CERTS_SITES/$DOMAIN.key" -out "$CERTS_SITES/$DOMAIN.csr"

cat > "$CERTS_SITES/$DOMAIN.ext" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN
EOF

openssl x509 -req -in "$CERTS_SITES/$DOMAIN.csr" -CA "$CERTS_PATH/myCA.pem" -CAkey "$CERTS_PATH/myCA.key" -CAcreateserial \
-out "$CERTS_SITES/$DOMAIN.crt" -days 825 -sha256 -extfile "$CERTS_SITES/$DOMAIN.ext"

# print file path for certificate in blue
printf "\033[01;34mCertificate generated in %s.crt\033[00m\n" "$CERTS_SITES/$DOMAIN"
printf "\033[01;34mCertificate generated in %s.key\033[00m\n" "$CERTS_SITES/$DOMAIN"

printf "You can use the certificate with in apache vhost like this:\n"
printf "\033[01;34mServerName %s\033[00m\n" "$DOMAIN"
printf "\033[01;34mSSLCertificateFile %s.crt\033[00m\n" "$CERTS_SITES/$DOMAIN"
printf "\033[01;34mSSLCertificateKeyFile %s.key\033[00m\n" "$CERTS_SITES/$DOMAIN"