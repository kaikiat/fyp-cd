#!/bin/bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

# Not needed 
# kubectl apply -f image_uploader/argocd-cm.yaml
# kubectl apply -f image_uploader/argocd-rbac-cm.yaml
# kubectl patch configmap/argocd-cm --patch-file image_uploader/argocd-cm.yaml -n argocd
# kubectl apply -f image_uploader/argocd-rbac-cm.yaml -n argocd


# API_KEY (seems useless ?)
# argocd account generate-token --account image-updater --id image-updater
# export API_KEY=
# kubectl create secret generic argocd-image-updater-secret \
#   --from-literal argocd.token=$API_KEY --dry-run -o yaml |
#   kubectl -n argocd apply -f -

# Set log to debug level
kubectl patch configmap/argocd-image-updater-config \
  -n argocd \
  --type merge \
  -p '{"data":{"log.level":"debug"}}'
kubectl patch configmap/argocd-image-updater-config --patch-file image_uploader/argocd-image-updater-config.yaml -n argocd
# kubectl get configmap argocd-image-updater-config -n argocd -o yaml


# GITHUB TOKEN
kubectl create secret generic git-creds \
  --from-literal=username=kaikiat \
  --from-literal=password=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 \
  -n argocd


kubectl -n argocd rollout restart deployment argocd-image-updater
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f



