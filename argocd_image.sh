#!/bin/bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

kubectl apply -f image_uploader/argocd-cm.yaml
kubectl apply -f image_uploader/argocd-rbac-cm.yaml

# API_KEY
argocd account generate-token --account image-updater --id image-updater
export API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJpbWFnZS11cGRhdGVyOmFwaUtleSIsIm5iZiI6MTY2MDM2MTk1OCwiaWF0IjoxNjYwMzYxOTU4LCJqdGkiOiJpbWFnZS11cGRhdGVyIn0.HEzxYOYjexkp48kuyOZwpTP8u-gQoCOFzCK9CSRAgf
kubectl create secret generic argocd-image-updater-secret \
  --from-literal argocd.token=$API_KEY --dry-run -o yaml |
  kubectl -n argocd apply -f -

  # Set log to debug level
kubectl patch configmap/argocd-image-updater-config \
  -n argocd \
  --type merge \
  -p '{"metadata":{"data":{"log.level":"debug"}}}'

# GITHUB TOKEN
kubectl create secret generic git-creds \
  --from-literal=username=kaikiat \
  --from-literal=password=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 \
  -n argocd

kubectl -n argocd rollout restart deployment argocd-image-updater



