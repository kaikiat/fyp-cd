kubectl port-forward svc/vault-internal  8200

curl -H "X-Vault-Token: s.xSoFGV2Z7LdnQQEuhjHpX4GN" \
     -H "X-Vault-Namespace: vault" \
     -X GET http://34.126.82.18:32000/v1/demo-app/data/user01?version=1

jwt_token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl --request POST \
    --data '{"jwt": "'$jwt_token'", "role": "webapp"}' \
    http://34.126.82.18:32000/v1/auth/kubernetes/login