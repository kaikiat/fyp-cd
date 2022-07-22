# # Add the Repo:
# helm repo add datawire https://app.getambassador.io
# helm repo update
 
# # Create Namespace and Install:
# kubectl create namespace ambassador && \
# kubectl apply -f https://app.getambassador.io/yaml/edge-stack/3.0.0/aes-crds.yaml
# kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
# helm install edge-stack --namespace ambassador datawire/edge-stack && \
# kubectl -n ambassador wait --for condition=available --timeout=90s deploy -lproduct=aes


# https://www.getambassador.io/docs/edge-stack/latest/tutorials/quickstart-demo/
# kubectl apply -f ambassador/mapping.yaml
# kubectl apply -f ambassador/quote.yaml
# export LB_ENDPOINT=$(kubectl -n ambassador get svc  edge-stack \
#   -o "go-template={{range .status.loadBalancer.ingress}}{{or .ip .hostname}}{{end}}")
curl -Lki https://$LB_ENDPOINT/backend/
