#!/bin/bash
set -x
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=SAMPLEISSUER/CN=SAMPLEISSUER" -out ca.crt
for i in name1 name2 name3; do
  DOMAIN=$i.infra.test.com
  cd $i
  openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=SAMPLEISSUER/CN=${DOMAIN}" -out server.csr
  openssl x509 -req -extfile <(printf "subjectAltName=DNS:${DOMAIN},DNS:www.${DOMAIN},IP:10.100.125.20,IP:87.245.186.246") -days 365 -in server.csr -CA ../ca.crt -CAkey ../ca.key -CAcreateserial -out server.crt
  kubectl delete secret $i-secret
  kubectl create secret tls $i-secret --key server.key --cert server.crt
  cd ../
done
