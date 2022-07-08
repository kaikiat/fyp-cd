kubectl config set-context --current --namespace prometheus
kubectl create namespace prometheus
helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus
kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090

## prom.yaml which endpont to scrap
## oper.yaml automate the configuration and management of the Prometheus
# targets http://localhost:9090/targets?search= 

kubectl apply -f prometheus_configuration/mongodb.yaml
# Add exporter
helm show values prometheus-community/prometheus-mongodb-exporter
helm install mongodb-exporter prometheus-community/prometheus-mongodb-exporter -f prometheus_configuration/values.yaml
kubectl port-forward service/mongodb-exporter-prometheus-mongodb-exporter 9216



