#!/bin/bash

BRANCH=${1-"master"}
NAMESPACE=${2-"vault-test"}
TEST=${3-"001-basic"}
LOCAL_HELM_CHART=${4}

if [ -z "${LOCAL_HELM_CHART}" ]; then
  rm -rf .chart
  mkdir -p .chart
  git clone git@github.com:ReadyTalk/vault-helm-chart.git .chart
  cd .chart; git checkout ${BRANCH}; cd ..
  LOCAL_HELM_CHART=".chart/helm_charts/vault"
fi

# ./clean_namespace.sh ${NAMESPACE}
kubectl create ns ${NAMESPACE}
helm upgrade --install \
  --namespace ${NAMESPACE} \
  --values test-values/${TEST}.yaml \
  vault-test \
  ${LOCAL_HELM_CHART}

# TODO: Wait for vault to come up...

../init/vault-init.sh vault-test vault-test true
../init/vault-unseal.sh vault-test vault-test
