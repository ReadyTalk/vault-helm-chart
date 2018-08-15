#!/bin/sh

HERITAGE=$(grep "heritage=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
RELEASE=$(grep "release=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
CHART=$(grep "chart=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')
COMPONENT=$(grep "component=" /etc/podinfo/labels | sed 's/^.*="\(.*\)"$/\1/')

kubectl delete secrets -l release=$RELEASE,component=$COMPONENT

# Create k8s Secret for Vault SSL Cert (The cert facing users)
cat /certs/$(ls /certs | grep ".*.crt.chain$") >> /certs/$(ls /certs | grep ".*.crt$")
kubectl create secret tls \
  $FULL_NAME.tls \
  --cert=/certs/$(ls /certs | grep ".*.crt$") \
  --key=/certs/$(ls /certs | grep ".*.key$")
kubectl label secret \
  $FULL_NAME.tls \
  heritage=$HERITAGE \
  release=$RELEASE \
  chart=$CHART \
  component=$COMPONENT
