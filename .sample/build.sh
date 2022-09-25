#!/bin/bash
export CR_PAT=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


export VERSION=0.0.5
docker build --tag python-docker:0.0.5 --platform=linux/amd64 .
docker tag python-docker:0.0.5 ghcr.io/kaikiat/python-docker:0.0.5
docker push ghcr.io/kaikiat/python-docker:0.0.5


echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
docker run --publish 8000:5000 python-docker


kubectl -n argocd rollout restart deployment argocd-image-updater
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f