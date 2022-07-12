kubectl create namespace monitoring
kubectl config set-context --current --namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090 -n monitoring
kubectl port-forward deployment/prometheus-grafana 3000 -n monitoring

# ArgoCD Helm
# https://github.com/argoproj/argo-cd/discussions/8968
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
# https://ishanjainn.medium.com/monitor-argocd-applications-using-prometheus-and-alertmanager-f96d7f39b060

##### Not used #####
helm repo add argo https://argoproj.github.io/argo-helm
# helm install argocd-release argo/argo-cd --namespace argocd
# helm upgrade argocd-release argo/argo-cd -f prometheus_configuration/values.yaml -n argocd
# helm uninstall argocd-release -n argocd

kubectl apply -f prometheus_configuration/service-monitor.yaml -n monitoring
kubectl apply -f prometheus_configuration/prometheus-rule.yaml -n monitoring

##### Grafana API key #####
# https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/grafana/
export GRAFANA_KEY=eyJrIjoiRUNKMG1HdnpDMVdTUTQ3REZ6SUtqc05qTWxIaVIzaXIiLCJuIjoiR1JBRkFOQV9LRVkiLCJpZCI6MX0=
kubectl apply -f prometheus_configuration/grafana-configmap.yaml -n monitoring
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.grafana-trigger.grafana":"argocd-grafana"}}}' --type merge
kubectl exec -it prometheus-grafana-66c78b7947-v2k4z -n monitoring --bash
