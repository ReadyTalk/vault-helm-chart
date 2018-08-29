#!/bin/sh
set -x

export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_SKIP_VERIFY=true
export VAULT_TOKEN=0371f985-9c07-260a-f044-10f9113abbde
export SERVICE_ACC="vault-tokenreview"

kubectl create serviceaccount ${SERVICE_ACC} 
export SECRET_NAME=$(kubectl get serviceaccount ${SERVICE_ACC} -o jsonpath='{.secrets[0].name}')
export TR_ACCOUNT_TOKEN=$(kubectl get secret ${SECRET_NAME} -o jsonpath='{.data.token}' | base64 --decode)

#export KUBE_API=$(kubectl cluster-info | head -1 | awk -F" " '{print $6}')
#export KUBE_API="https://api.ac.fuze.tikal.io"
export KUBE_API="https://192.168.99.105:8443"
kubectl apply -f vault-token-sa2.yaml

vault status
vault auth enable approle
vault auth enable kubernetes

vault write auth/kubernetes/config \
    token_reviewer_jwt="${TR_ACCOUNT_TOKEN}" \
    kubernetes_host=${KUBE_API} \
    kubernetes_ca_cert=@minikube.ca.crt

vault write sys/policy/demo-policy policy=@policy.hcl
vault write auth/kubernetes/role/demo-role \
    bound_service_account_names=default \
    bound_service_account_namespaces=default \
    policies=demo-policy \
    ttl=8h

vault write auth/approle/role/demo-role \
    secret_id_ttl=1h \
    secret_id_num_uses=10 \
    period=24h \
    bind_secret_id="true" \
    policies="demo-policy"
    token_num_uses=10
    token_ttl=1h

#vault write auth/approle/role/demo \
#    secret_id_ttl=1h \
#    token_num_uses=4 \
#    token_ttl=1h \
#    token_max_ttl=1h \
#    secret_id_num_uses=40

export ROLE_ID=$(vault read -format=json auth/approle/role/demo-role/role-id | jq -r '.data.role_id')
export SECRET_ID=$(vault write -format=json -f auth/approle/role/demo-role/secret-id | jq -r '.data.secret_id')


