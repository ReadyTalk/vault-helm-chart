#!/bin/sh

HERITAGE=$(grep "heritage=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
RELEASE=$(grep "release=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
CHART=$(grep "chart=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
COMPONENT=$(grep "component=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')

kubectl delete secrets -l release=$RELEASE,component=$COMPONENT

# Create K8s Secret for Consul Gossip Key in a json format so it can be mounted
# It seems that k8s doesn't like to use JSON with --from-literal=
GOSSIPKEY=$(cat /dev/urandom | head -c 24 | base64; echo)
echo "{\"encrypt\": \"$GOSSIPKEY\"}" > encrypt.json
kubectl create secret generic \
  $FULL_NAME-consul-gossip-json \
  --from-file=encrypt.json
rm -rf encrypt.json
kubectl label secret \
  $FULL_NAME-consul-gossip-json \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT

# Create k8s Secret for Consul CA
kubectl create secret generic \
  $FULL_NAME-consul.ca \
  --from-file=/certs/cert/ca.crt.pem
kubectl label secret \
  $FULL_NAME-consul.ca \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT

# Create k8s Secret for Consul TLS Cert
kubectl create secret tls \
  $FULL_NAME-consul.tls \
  --cert=/certs/cert/consul.crt.pem \
  --key=/certs/private/consul.key.pem
kubectl label secret \
  $FULL_NAME-consul.tls \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT
