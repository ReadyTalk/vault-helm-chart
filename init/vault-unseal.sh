if [ $# -lt 2 ]
  then
    echo "Invalid arguments provided"
    echo "Valid usage: "`basename "$0"`" <release-name> <namespace> <flags(optional)>"
    exit 1
fi

RELEASE=$1
NAMESPACE=$2
COMPONENT="${RELEASE}-vault"
REQUIRED_KEY_COUNT=3

SECRET_NAME="$RELEASE-vault-keys"

echo "Getting unseal keys from Kubernetes secret"
UNSEAL_KEYS=$(kubectl get secret -n $NAMESPACE ${SECRET_NAME} -o yaml | grep -e "key[0-9]\:" | awk '{print $2}')

for i in `seq 1 $REQUIRED_KEY_COUNT`;
do
  KEY=$(echo "$UNSEAL_KEYS"  | sed "${i}q;d" | base64 --decode)
  kubectl get po -l component=$COMPONENT,release=$RELEASE -n $NAMESPACE \
      | awk '{if(NR>1)print $1}' \
      | xargs -I % kubectl exec -n $NAMESPACE -c $RELEASE % -- sh -c "vault operator unseal --tls-skip-verify $KEY";
done
