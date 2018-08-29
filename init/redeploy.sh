#!/bin/bash
set -x
export REL=${1-"secret"}
export NAMESPACE=${2-"vault"}

helm del --purge ${REL} || /usr/bin/true
kubectl delete configmap,job ${REL}-vault-consul-preinstall ${REL}-vault-vault-preinstall || /usr/bin/true
helm install --name ${REL} --namespace ${NAMESPACE} helm_charts/vault
helm list | grep ${REL}
