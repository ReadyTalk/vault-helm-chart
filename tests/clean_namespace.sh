#!/bin/bash

CLUSTER=$(kubectl config current-context)
NAMESPACE=${1}

kubectl get ns ${NAMESPACE} > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "Deleting the following namespace on cluster ${CLUSTER}"
  echo ${NAMESPACE}
  read -r -p "Continue? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
  then
    kubectl delete ns ${NAMESPACE}
  fi
fi
