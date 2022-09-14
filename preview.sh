#!/bin/bash
export KUBE_NAME=sgdecoding-online-scaled
export NAMESPACE=ntuasr-production-google

export MASTER_SERVICE="$KUBE_NAME-master-preview"  
export MASTER_SERVICE_IP=$(kubectl get svc $MASTER_SERVICE -n $NAMESPACE \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
export MASTER_ENDPOINT=$(kubectl describe svc sgdecoding-online-scaled-master | grep 'Endpoints:')
echo "Master Endpoint:  ${MASTER_ENDPOINT}" 
echo "IP addess of master: ${MASTER_SERVICE_IP}"

python3 client/client_3_ssl.py -u ws://$MASTER_SERVICE_IP/client/ws/speech -r 32000 -t abc --model="SingaporeCS_0519NNET3" client/audio/episode-1-introduction-and-origins.wav --preview