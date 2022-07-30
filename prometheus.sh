kubectl create namespace prometheus
kubectl config set-context --current --namespace prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus
helm uninstall prometheus --namespace prometheus
# Check targets to see if argocd exists?
kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090 -n prometheus
kubectl port-forward deployment/prometheus-grafana 3000 -n prometheus

# ArgoCD Helm
# https://github.com/argoproj/argo-cd/discussions/8968
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
# https://ishanjainn.medium.com/monitor-argocd-applications-using-prometheus-and-alertmanager-f96d7f39b060

##### Not used #####
helm repo add argo https://argoproj.github.io/argo-helm
# helm install argocd-release argo/argo-cd --namespace argocd
# helm upgrade argocd-release argo/argo-cd -f prometheus_configuration/values.yaml -n argocd
# helm uninstall argocd-release -n argocd

kubectl apply -f prometheus_configuration/service-monitor.yaml -n argocd
# After argo-rollouts is created
kubectl apply -f prometheus_configuration/service-monitor-argorollouts.yaml -n argo-rollouts
kubectl apply -f prometheus_configuration/service-monitor-ntuasr.yaml -n ntuasr-production-google
# Not working
# kubectl apply -f prometheus_configuration/prometheus-rule.yaml -n prometheus

##### Grafana API key #####
# https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/grafana/
export GRAFANA_KEY=eyJrIjoiRUNKMG1HdnpDMVdTUTQ3REZ6SUtqc05qTWxIaVIzaXIiLCJuIjoiR1JBRkFOQV9LRVkiLCJpZCI6MX0=
kubectl apply -f prometheus_configuration/grafana-configmap.yaml -n prometheus
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.grafana-trigger.grafana":"argocd-grafana"}}}' --type merge
kubectl exec -it prometheus-grafana-66c78b7947-v2k4z -n prometheus --bash