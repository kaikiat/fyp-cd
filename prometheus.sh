kubectl config set-context --current --namespace prometheus
kubectl create namespace prometheus
helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus
kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090 -n prometheus
kubectl port-forward deployment/prometheus-grafana 3000 -n prometheus


## prom.yaml which endpont to scrap
## oper.yaml automate the configuration and management of the Prometheus
# targets http://localhost:9090/targets?search= 

kubectl apply -f prometheus_configuration/mongodb.yaml
helm show values prometheus-community/prometheus-mongodb-exporter
helm install mongodb-exporter prometheus-community/prometheus-mongodb-exporter -f prometheus_configuration/values.yaml
kubectl port-forward service/mongodb-exporter-prometheus-mongodb-exporter 9216

# ArgoCD Helm
# https://github.com/argoproj/argo-cd/discussions/8968
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

helm repo add argo https://argoproj.github.io/argo-helm
# Why cannot use argocd ? But argocd-release works
# helm install argocd-release argo/argo-cd -f prometheus_configuration/values.yaml -n argocd
# helm install argocd argo/argo-cd -f prometheus_configuration/values.yaml -n argocd
helm install argocd-release argo/argo-cd --namespace argocd
helm upgrade argocd-release argo/argo-cd -f prometheus_configuration/values.yaml -n argocd
helm uninstall argocd-release -n argocd
# Add argocd service monitor

kubectl apply -f prometheus_configuration/service-monitor.yaml
