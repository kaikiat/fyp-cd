#!/bin/bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

# Set log to debug level
kubectl patch configmap/argocd-image-updater-config \
  -n argocd \
  --type merge \
  -p '{"data":{"log.level":"debug"}}'
kubectl patch configmap/argocd-image-updater-config --patch-file image_uploader/argocd-image-updater-config.yaml -n argocd

# GITHUB TOKEN
kubectl apply -f image_uploader/secrets.yaml
kubectl -n argocd rollout restart deployment argocd-image-updater
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f



