#!/bin/bash

if [ $# -lt 2 ]
  then
    echo "Invalid arguments provided"
    echo "Valid usage: "`basename "$0"`" <release-name> <namespace> <flags(optional>)"
    exit 1
fi

RELEASE=$1
NAMESPACE=$2
CHART_NAME="vault"
COMPONENT="${RELEASE}-vault"
ADD_SECRET=${3-"false"}

SECRET_NAME="$RELEASE-vault-keys"

LABELS=$(kubectl get secret -l release=$RELEASE -n $NAMESPACE --show-labels | sed -n 2p | awk '{print $5}' | sed 's/\,/ /g')
FIRST_VAULT_POD=$(kubectl get po -l component=$COMPONENT,release=$RELEASE -n $NAMESPACE | awk '{if(NR==2)print $1}')
INIT_MESSAGE=$(kubectl exec -n $NAMESPACE -c $RELEASE $FIRST_VAULT_POD -- sh -c "vault operator init --tls-skip-verify" 2>&1)

echo "$INIT_MESSAGE"
if [[ ${INIT_MESSAGE} != *"Error initializing Vault"* && "${ADD_SECRET}" == "true"  ]]; then
  echo
  echo
  echo "Deleting existing Vault key secret"
  kubectl delete secret -n $NAMESPACE $SECRET_NAME --ignore-not-found=true
  echo "Creating Vault key secret: $SECRET_NAME"
  KEYS=$(echo "$INIT_MESSAGE" | grep "Unseal Key" | awk '{print $4}')
  CREATE_SECRET_COMMAND="kubectl create secret generic $SECRET_NAME -n $NAMESPACE "
  COUNT=1
  for i in ${KEYS[@]};
  do
    CREATE_SECRET_COMMAND="$CREATE_SECRET_COMMAND --from-literal=key$COUNT=$i"
    COUNT=$((COUNT+1))
  done
  $(echo $CREATE_SECRET_COMMAND)
  kubectl label secret -n $NAMESPACE \
    $SECRET_NAME \
    $LABELS
  kubectl label secret -n $NAMESPACE \
    --overwrite \
    $SECRET_NAME \
    component="${RELEASE}-vault-init"
fi
