#!/bin/bash
# The goal of this script is to create the needed certs for Vault to Consul TLS communication
# This script can be run every time there is a deployment of the helm chart
# Notes:
#  It seems that openssl.cnf will not take ENV variables for the common name with like ${ENV::TLS_COMMON_NAME}
#  https://stackoverflow.com/questions/8075274/is-it-possible-making-openssl-skipping-the-country-common-name-prompts

export ALTNAMECONSUL=server.$DATACENTER.consul

# Having a cert signed with localhost is only used to bfuscate traffic from like sysdig tools running as privileged
export ALTNAMEVAULT=localhost

# These values will be used in the signed certs
countryName=$TLS_COUNTRY_NAME
localityName=$TLS_LOCALITY_NAME
emailAddress=$TLS_EMAIL_ADDRESS
organizationName=$TLS_ORGANIZATION_NAME
stateOrProvinceName=$TLS_STATE_OR_PROVINCE_NAME
organizationalUnitName=$TLS_ORGANIZATION_UNIT_NAME
# Common name will be  added per cert with variables below and extensions options from the openssl.cnf

# Lets delete all created certs and start over when  this script is ran
mkdir -p /certs
rm -rf /certs/*
touch /certs/certindex
touch /certs/index.txt
touch /certs/index.txt.attr
echo 000a > /certs/serial
mkdir -p /certs/private
mkdir -p /certs/cert
mkdir -p /certs/csr

# CA certs
echo "Creating CA..."
commonName='vault-ca'
cmd="openssl req -config ./openssl.cnf \
      -newkey rsa -days 3650 -x509 -nodes -extensions v3_ca \
      -subj /C=${countryName}/ST=${stateOrProvinceName}/L=${localityName}/O=${organizationName}/OU=${organizationalUnitName}/CN=${commonName} \
      -out /certs/cert/ca.crt.pem \
      -keyout /certs/private/ca.key.pem"
$cmd
if [[ $? -ne 0 ]] ; then
  echo -e "\n\nERROR: CA certificate request not valid"; exit 1
fi

# Consul certs (client/server)
echo "Creating Consul cert..."
commonName='consul'
cmd="openssl req -config ./openssl.cnf \
      -newkey rsa -nodes \
      -subj /C=${countryName}/ST=${stateOrProvinceName}/L=${localityName}/O=${organizationName}/OU=${organizationalUnitName}/CN=${commonName} \
      -out /certs/csr/${commonName}.csr.pem \
      -keyout /certs/private/${commonName=}.key.pem"
$cmd &>/dev/null
if [[ $? -ne 0 ]] ; then
  echo -e "\n\nERROR: Consul certificate request not valid"; exit 1
fi

cmd="openssl ca -batch -config ./openssl.cnf \
      -notext -extensions server_cert -notext \
      -in /certs/csr/${commonName}.csr.pem \
      -subj /C=${countryName}/ST=${stateOrProvinceName}/L=${localityName}/O=${organizationName}/OU=${organizationalUnitName}/CN=${commonName} \
      -out /certs/cert/${commonName=}.crt.pem"
$cmd &>/dev/null
if [[ $? -ne 0 ]] ; then
  echo -e "\n\nERROR: Consul certificate request not valid"; exit 1
fi
