
# https://blog.searce.com/ambassador-with-google-kubernetes-engine-gke-d80571ef0525
# https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs

# Add the Repo:
helm repo add datawire https://app.getambassador.io
helm repo update
 
# Create Namespace and Install:
kubectl create namespace ambassador && \
kubectl apply -f https://app.getambassador.io/yaml/edge-stack/3.1.0/aes-crds.yaml
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
helm install edge-stack --namespace ambassador datawire/edge-stack && \
kubectl -n ambassador wait --for condition=available --timeout=90s deploy -lproduct=aes

kubectl apply -f managed-cert-ingress.yaml

kubectl apply -f - <<EOF
---
apiVersion: getambassador.io/v3alpha1
kind: Listener
metadata:
 name: emissary-ingress-listener-8080
 namespace: emissary
spec:
 port: 8080
 protocol: HTTP
 securityModel: XFP
 hostBinding:
   namespace:
     from: ALL
EOF

kubectl apply -f ambassador.yaml 
kubectl apply -f cert.yaml

kubectl apply -f - <<EOF
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: basic-ingress
spec:
  backend:
    serviceName: ambassador
    servicePort: 8080
EOF

kubectl apply -f ingress.yaml 

# Reserve the IP address
gcloud services enable dns.googleapis.com 

# Visit this page to configure SSL
gcloud compute ssl-certificates create ntuasr-cert \
    --description="ntuasr.com ssl cert" \
    --domains=ntuasr.com \
    --global

gcloud compute target-https-proxies update k8s2-um-p6evmkpf-ntuasr-production-google-basic-ingres-mk8ebeke \
    --ssl-certificates ntuasr-cert \
    --global-ssl-certificates \
    --global

