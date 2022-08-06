# # Add the Repo:
# helm repo add datawire https://app.getambassador.io
# helm repo update
 
# # Create Namespace and Install:
# kubectl create namespace ambassador && \
# kubectl apply -f https://app.getambassador.io/yaml/edge-stack/3.0.0/aes-crds.yaml
# kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
# helm install edge-stack --namespace ambassador datawire/edge-stack && \
# kubectl -n ambassador wait --for condition=available --timeout=90s deploy -lproduct=aes

###################

# Refer to https://www.getambassador.io/docs/argo/latest/howtos/configure-argo-rollouts/
kubectl apply -f https://app.getambassador.io/yaml/edge-stack/3.1.0/aes-crds.yaml && \
kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
kubectl apply -f https://app.getambassador.io/yaml/edge-stack/3.1.0/aes.yaml && \
kubectl -n ambassador wait --for condition=available --timeout=90s deploy -lproduct=aes

kubectl get deploy --namespace ambassador edge-stack -o jsonpath='{.spec.template.spec.containers[0].image}'

# Adjust the api version of EdgeStack
kubectl patch deployment -n argo-rollouts \
    $(kubectl get -nargo-rollouts -l app.kubernetes.io/component=rollouts-controller deploy -o=jsonpath='{.items[].metadata.name}') \
    -p '{"spec":{"template":{"spec":{"containers":[{"name":"argo-rollouts", "args":["--ambassador-api-version","getambassador.io/v3alpha1"]}]}}}}'

sudo curl -fL https://metriton.datawire.io/downloads/darwin/edgectl \
  -o /usr/local/bin/edgectl && \
sudo chmod a+x /usr/local/bin/edgectl

kubectl apply -f ./manifests --namespace ntuasr-production-google 

# Click Existing, Edge Stack
# Assuming your installation is in the ambassador namespace, run:
kubectl create configmap --namespace ambassador edge-stack-agent-cloud-token --from-literal=CLOUD_CONNECT_TOKEN=NWZjYzQxNWYtNjU2MS00OGNlLTgwZmEtMTdhMTM0Y2VhNGIyOnJyblo3V3BqTnludXhIZTFWRWxNTXlYaFpzTHdCblJkQ0dKZg==



