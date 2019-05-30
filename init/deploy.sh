#!/bin/bash

#set -x
REL=${1-"dev"}
NAMESPACE=${2-"default"}
DEPLOY_DIR=$(pwd)

echo "----------------------------- Purging ----------------------------"
helm del --purge ${REL} || /usr/bin/true
kubectl delete configmap,job ${REL}-vault-consul-preinstall ${REL}-vault-vault-preinstall || /usr/bin/true

echo "----------------------------- Installing -------------------------"
helm install --name ${REL} --namespace ${NAMESPACE} ../helm_charts/vault
RC=$?
helm list | grep ${REL}

if [ $RC -eq 0 ]
then
  echo -n " "
  i=1
  sp="/-\|"
  echo -n ' '
  RUNNING=0
  while [ ${RUNNING} -lt 3 ];
  do
      sleep 1
      printf "\b${sp:i++%${#sp}:1}"
  done
else
    exit
fi

# TODO FIXME smarter way to wait_for vault
echo "----------------------------- Initializing -----------------------"
sleep 10
exec ${DEPLOY_DIR}/vault-init.sh ${REL} ${NAMESPACE}

#echo "----------------------------- Unsealing --------------------------"
sleep 5
exec ${DEPLOY_DIR}/vault-unseal.sh ${REL} ${NAMESPACE}
