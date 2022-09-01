#!/bin/bash
brew install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Username is admin (Login via web-ui preferably)
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl port-forward svc/sgdecoding-online-scaled-master -n ntuasr-production-google 8081
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Login via cli
# argocd login localhost:8080
argocd login localhost:8080 --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd repo list

########################## For demo-app ##########################
# Only argo apply (Argo's configuration)
kubectl apply -f application.yaml
# Install grafana and prometheus now


# Argocd documetation states id_rsa but github does not accept id_rsa

# If not generated yet
ssh-keygen -t ed25519 -C "pohkaikiat98@gmail.com"
# cat /Users/kaikiat/.ssh/id_ed25519.pub
cat /$HOME/.ssh/id_ed25519.pub

# From docs
# argocd repo add git@github.com:kaikiat/fyp.git --ssh-private-key-path ~/.ssh/id_rsa 
# argocd repo add git@github.com:kaikiat/fyp-cd.git --ssh-private-key-path ~/.ssh/id_rsa 
# For ubuntu
argocd repo add git@github.com:kaikiat/fyp-cd.git --ssh-private-key-path ~/.ssh/id_ed25519

# For macOs
argocd repo add git@github.com:kaikiat/fyp-cd.git --ssh-private-key-path ~/.ssh/id_ecdsa
argocd repo add git@github.com:kaikiat/fyp-cd.git --ssh-private-key-path ~/.ssh/id_rsa
argocd repo list
argocd app list  # to get app

# ssh-keygen -t id_ecdsa -C "pohkaikiat98@gmail.com"

## Can a pull request trigger the flow -> works
## Can a normal commit trigger the flow -> yes works
# argocd app sync sgdecoding-staging

# how to delete
argocd app delete sgdecoding-online-scaled
kubectl get namespace argocd -o json >tmp.json
kubectl proxy
curl -k -H "Content-Type: application/json" -X PUT -d @tmp.json http://127.0.0.1:8001/api/v1/namespaces/argocd/finalize

# https://www.reddit.com/r/kubernetes/comments/jc207l/argocd_and_broken_namespaces/

#################################################################


########################## argo rollout ##########################
# kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
# Installing and configuring prometheus
# kubectl apply -n argo-rollouts -f rollout.yaml

# Argo rollout plugin installation
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-darwin-amd64
chmod +x ./kubectl-argo-rollouts-darwin-amd64
sudo mv ./kubectl-argo-rollouts-darwin-amd64 /usr/local/bin/kubectl-argo-rollouts

# Install controller
kubectl create namespace argo-rollouts
# If using helm (https://argoproj.github.io/argo-rollouts/features/controller-metrics/)
# Must install prometheus first
helm install argo-rollouts argo_rollouts --namespace argo-rollouts
helm upgrade argo-rollouts argo_rollouts --namespace argo-rollouts
helm uninstall argo-rollouts --namespace argo-rollouts
# kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
# Do I need this if using helm
# kubectl create clusterrolebinding kaikiat-cluster-admin-binding --clusterrole=cluster-admin --user=kaikiatpoh14@gmail.com

# Refer to this for helm-argocd 
# https://github.com/argoproj/argo-rollouts/tree/master/examples/helm-blue-green

# Combining argocd and rollout
kubectl apply -f argo_production/ntuasr/application.yaml
kubectl delete -f argo_production/ntuasr/application.yaml
kubectl get rollouts 

# Deploying the initial verion (use helm install ?)
kubectl argo rollouts abort sgdecoding-online-scaled-master

# Watch
kubectl argo rollouts get rollout sgdecoding-online-scaled-master --watch # why doesnt this work ?
kubectl argo rollouts get rollout sgdecoding-online-scaled-worker-singaporecs-0519nnet3 --watch

# The initial deployment
helm install sgdecoding-online-scaled argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/
helm lint sgdecoding-online-scaled argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/
helm install sgdecoding-production argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/
helm lint sgdecoding-production argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/


# Delete deployment
helm uninstall sgdecoding-online-scaled argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/

# Setting up UI
kubectl-argo-rollouts dashboard -n ntuasr-production-google
kubectl-argo-rollouts list rollouts

# The second deployment
# helm upgrade --install sgdecoding-online-scaled argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/ --set image.repository=ghcr.io/kaikiat/fyp-1:latest
# helm upgrade --install sgdecoding-online-scaled argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/ --set image.repository=ghcr.io/kaikiat/ntu-asr-image:latest
helm upgrade --install sgdecoding-production argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/ --set image.repository=ghcr.io/kaikiat/fyp-1:latest
helm upgrade --install sgdecoding-production argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/ --set image.repository=ghcr.io/kaikiat/ntu-asr-image:latest

--install sgdecoding-online-scaled argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled/ \
--set image.repository=ghcr.io/kaikiat/fyp-1:latest


# Reference
# 1. Combine rollout and app (https://www.youtube.com/watch?v=35Qimb_AZ8U&ab_channel=GeertBaeke)
# To promote deployment
kubectl-argo-rollouts promote --full sgdecoding-online-scaled-master 
kubectl-argo-rollouts promote --full sgdecoding-online-scaled-worker-singaporecs-0519nnet3 
kubectl-argo-rollouts promote --full sgdecoding-online-scaled-worker-singaporemandarin-0519nnet3 

# Helm if statements , refer: https://renehernandez.io/snippets/customize-api-version-helm-templates/

# Deleting argo namespace (remove kubernetes from finalizers)
python3 -c "namespace='argocd';import atexit,subprocess,json,requests,sys;proxy_process = subprocess.Popen(['kubectl', 'proxy']);atexit.register(proxy_process.kill);p = subprocess.Popen(['kubectl', 'get', 'namespace', namespace, '-o', 'json'], stdout=subprocess.PIPE);p.wait();data = json.load(p.stdout);data['spec']['finalizers'] = [];requests.put('http://127.0.0.1:8001/api/v1/namespaces/{}/finalize'.format(namespace), json=data).raise_for_status()"


##### Slack service #####
Refer to https://rinseodam.medium.com/notification-argocd-to-slack-292ce01d203b
https://argocd-notifications.readthedocs.io/en/latest/services/slack/

# Install argocd notifications
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml
# Install Triggers and Templates from the catalog (Added data.service)
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/catalog/install.yaml
kubectl apply -n argocd -f config.yaml
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-succeeded.slack":"#argocd"}}}' --type merge
# Are you sure it is on-sync-unknown
# kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-unknown.slack":"#argocd"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-status-unknown.slack":"#argocd"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-failed.slack":"#argocd"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-health-degraded.slack":"#argocd"}}}' --type merge

##### Email service #####
# export EMAIL_USER=kaikiat@nonscriberabbit.com \
# export PASSWORD=zrlfubbvwhppaxsd 
# kubectl apply -n argocd -f - << EOF
# apiVersion: v1
# kind: Secret
# metadata:
#   name: argocd-notifications-secret
# stringData:
#   email-username: $EMAIL_USER
#   email-password: $PASSWORD
# type: Opaque
# EOF

# on.sync-failed.gmail not working
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"recipients.argocd-notifications.argoproj.io":"kaikiatpoh14@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-succeeded.gmail":"kaikiatpoh14@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-failed.gmail":"kaikiatpoh14@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-status-unknown.gmail":"kaikiatpoh14@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-health-degraded.gmail":"kaikiatpoh14@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-deployed.gmail":"kaikiatpoh14@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-running.gmail":"kaikiatpoh14@gmail.com"}}}' --type merge

