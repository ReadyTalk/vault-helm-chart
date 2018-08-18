#!/bin/bash

#set -x
REL=${1-"secret"}
NAMESPACE=${2-"vault"}
DEPLOY_DIR=$(pwd)

echo "----------------------------- Purging ----------------------------"
helm del --purge ${REL} || /usr/bin/true
kubectl delete configmap,job ${REL}-vault-consul-preinstall ${REL}-vault-vault-preinstall || /usr/bin/true

echo "----------------------------- Installing -------------------------"
helm install --name ${REL} --namespace ${NAMESPACE} ../helm_charts/vault
helm list | grep ${REL}

echo -n "Loading vault -> "
i=1
sp="/-\|"
echo -n ' '
RUNNING=0
while [ ${RUNNING} -lt 3 ];
do
    sleep 1
    echo -n "RUNNING: ${RUNNING}  "
    RUNNING=$(kubectl -n vault get pods -l=component=${REL}-vault | grep Running | wc -l)
    printf "\b${sp:i++%${#sp}:1}"
done

# TODO FIXME smarter way to wait_for vault
#echo "----------------------------- Initializing -----------------------"
#sleep 10
#${DEPLOY_DIR}/vault-init.sh ${REL} ${NAMESPACE}

#echo "----------------------------- Unsealing --------------------------"
#${DEPLOY_DIR}/vault-init.sh ${REL} ${NAMESPACE}
