#!/bin/bash
# Create project in gcp + enable billing + link a billing account
# Delete .terraform + create gcs bucket
# gcloud auth login
# gcloud auth application-default login
export PROJECT_ID=cube-17
export GITHUB_USERNAME=kaikiat
export CR_PAT=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 
export GITLAB_USERNAME=benjaminc812
export GITLAB_PASSWORD=glpat-pa7YfxjHZxpTztcd8WHH
export GITLAB_EMAIL=benjaminc8121@gmail.co
gcloud config set project $PROJECT_ID
gcloud services enable container.googleapis.com
gcloud services enable file.googleapis.com
gcloud services enable compute.googleapis.com

# #Terraform will set up application resources
# cd Terraform_google || exit
# terraform init
# terraform validate
# terraform plan
# terraform apply -auto-approve

# # # Create role (done in Terraform directory)
# gcloud iam roles create Terraform_role \
#   --file=Terraform_role.yaml \
#   --project $PROJECT_ID

# # # Bind role Select none (change project id)
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
#     --role="projects/${PROJECT_ID}/roles/Terraform_role"
# cd .. 

# ssh into one of the vm
# mount the filestore onto vm

# mkdir mnt
# sudo mount <filstore ip>:/<filestore path> <mount directory>
# example: sudo mount 192.168.185.66:/modelshare mnt
# sudo chmod go+rw mnt (sudo chmod -R 777 mnt if on linux after loading)
# pwd # must use the full path of the mount directory for scp command

# Upload model to Google File Store before SCP 
# export VM_ID=gke-gke-ntu-asr-clus-ntu-asr-node-poo-e0e19dcd-n224
# export PWD=/home/kaikiat/mnt
# export REMOTE_DIR=/home/kaikiat/mnt
# gcloud compute scp models/SingaporeCS_0519NNET3 $VM_ID:$PWD --project=$PROJECT_ID --zone=asia-southeast1-a --recurse

##### Initial Infrastructure setup #####
# export KUBE_NAME=sgdecoding-online-scaled
# export NAMESPACE=ntuasr-production-google
# gcloud container clusters get-credentials gke-ntu-asr-cluster --zone asia-southeast1-a --project $PROJECT_ID
# kubectl create namespace $NAMESPACE
# kubectl config set-context --current --namespace $NAMESPACE
# kubectl apply -f secret/run_kubernetes_secret.yaml
# kubectl apply -f google_pv/  # need to change the ip address of the pvc, need to delete pv when rerunning
# kubectl create secret docker-registry regcred --docker-server=ghcr.io --docker-username=$GITHUB_USERNAME --docker-password=$CR_PAT --docker-email=$GITHUB_EMAIL --namespace $NAMESPACE
# kubectl create secret docker-registry regcred2 --docker-server=registry.gitlab.com --docker-username=$GITLAB_USERNAME --docker-password=$GITLAB_PASSWORD --docker-email=$GITLAB_EMAIL --namespace $NAMESPACE


##### Testing #####
# export KUBE_NAME=sgdecoding-online-scaled
# export NAMESPACE=ntuasr-production-google

# export MASTER_SERVICE="$KUBE_NAME-master"  
# # export MASTER_SERVICE="$KUBE_NAME-master-preview"  
# export MASTER_SERVICE_IP=$(kubectl get svc $MASTER_SERVICE -n $NAMESPACE \
#     --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
# export MASTER_ENDPOINT=$(kubectl describe svc sgdecoding-online-scaled-master | grep 'Endpoints:')
# echo "Master Endpoint:  ${MASTER_ENDPOINT}" 
# echo "IP addess of master: ${MASTER_SERVICE_IP}"

# if [[ $MASTER_SERVICE == *"preview"* ]]; then
#     # python3 client/client_3_ssl.py -u ws://$MASTER_SERVICE_IP/client/ws/speech -r 32000 -t abc --model="SingaporeCS_0519NNET3" client/audio/episode-1-introduction-and-origins.wav --preview
#     python3 client/client_3_ssl.py -u ws://$MASTER_SERVICE_IP/client/ws/speech -r 32000 -t abc --model="SingaporeCS_0519NNET3" client/audio/episode-1-introduction-and-origins.wav
# else 
#     python3 client/client_3_ssl.py -u ws://$MASTER_SERVICE_IP/client/ws/speech -r 32000 -t abc --model="SingaporeCS_0519NNET3" client/audio/episode-1-introduction-and-origins.wav
# fi

