kubectl config set-context --current --namespace prometheus
kubectl create namespace prometheus
helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus
kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090 -n prometheus
kubectl port-forward deployment/prometheus-grafana 3000 -n prometheus

# ArgoCD Helm
# https://github.com/argoproj/argo-cd/discussions/8968
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

##### Not used #####
helm repo add argo https://argoproj.github.io/argo-helm
# Why cannot use argocd ? But argocd-release works
helm install argocd-release argo/argo-cd --namespace argocd
helm upgrade argocd-release argo/argo-cd -f prometheus_configuration/values.yaml -n argocd
helm uninstall argocd-release -n argocd

kubectl apply -f prometheus_configuration/service-monitor.yaml

# https://ishanjainn.medium.com/monitor-argocd-applications-using-prometheus-and-alertmanager-f96d7f39b060
