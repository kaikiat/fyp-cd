#!/bin/bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml


kubectl apply -f image_uploader/argocd-cm.yaml
argocd account generate-token --account image-updater --id image-updater

export API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJpbWFnZS11cGRhdGVyOmFwaUtleSIsIm5iZiI6MTY2MDE0MDE5OCwiaWF0IjoxNjYwMTQwMTk4LCJqdGkiOiJpbWFnZS11cGRhdGVyIn0.O4cJsgDpnldGSzho3yGG_1lXAHmZgP8CRwMwxme7R3c

kubectl apply -f image_uploader/argocd-rbac-cm.yaml
