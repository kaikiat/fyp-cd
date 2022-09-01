# kubectl create namespace ambassador && \
kubectl delete -f https://app.getambassador.io/yaml/edge-stack/3.1.0/aes-crds.yaml
# kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
helm uninstall edge-stack --namespace ambassador datawire/edge-stack
