# Create project in gcp + enable billing + link a billing account
# Delete .terraform + create gcs bucket
# gcloud auth login
# gcloud auth application-default login
export PROJECT_ID=cube-15
export GITHUB_USERNAME=kaikiat
export CR_PAT=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 
export CR_PAT2=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

export GITLAB_USERNAME=benjaminc8121
export GITLAB_PASSWORD=glpat-pa7YfxjHZxpTztcd8WHH
export GITLAB_EMAIL=benjaminc8121@gmail.com


# gcloud config set project $PROJECT_ID
# gcloud services enable container.googleapis.com
# gcloud services enable file.googleapis.com
# gcloud services enable compute.googleapis.com

# ## Terraform will set up application resources
# cd Terraform_google || exit
# terraform init
# terraform validate
# terraform plan
# terraform apply -auto-approve

# # # Create role (done in Terraform directory)
# gcloud iam roles create Terraform_role \
#   --file=Terraform_role.yaml \
#   --project $PROJECT_ID

# # Bind role Select none (change project id)
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#     --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
#     --role="projects/${PROJECT_ID}/roles/Terraform_role"
# cd .. 

# ssh into one of the vm
# mount the filestore onto vm

# mkdir mnt
# sudo mount <filstore ip>:/<filestore path> <mount directory>
# example: sudo mount 10.118.106.226:/modelshare mnt
# sudo chmod go+rw mnt (sudo chmod -R 777 mnt if on linux after loading)
# pwd # must use the full path of the mount directory for scp command

# Upload model to Google File Store before SCP 
# export VM_ID=gke-gke-ntu-asr-clus-ntu-asr-node-poo-d88b3fd0-8xd1
# export PWD=/home/kaikiat/mnt
# export REMOTE_DIR=/home/kaikiat/mnt
# gcloud compute scp models/SingaporeCS_0519NNET3 $VM_ID:$PWD --project=$PROJECT_ID --zone=asia-southeast1-a --recurse


##### Staging #####
# export KUBE_NAME=sgdecoding-staging
# export NAMESPACE=ntuasr-staging-google
# gcloud container clusters get-credentials gke-ntu-asr-cluster --zone asia-southeast1-a --project $PROJECT_ID
# kubectl create namespace $NAMESPACE
# kubectl config set-context --current --namespace $NAMESPACE
# kubectl apply -f google_staging/secret/run_kubernetes_secret.yaml
# kubectl apply -f google_staging/google_pv/
# kubectl create secret docker-registry regcred --docker-server=ghcr.io --docker-username=$GITHUB_USERNAME --docker-password=$CR_PAT --docker-email=$GITHUB_EMAIL --namespace $NAMESPACE
# kubectl create secret docker-registry regcred2 --docker-server=registry.gitlab.com --docker-username=$GITLAB_USERNAME --docker-password=$GITLAB_PASSWORD --docker-email=$GITLAB_EMAIL --namespace $NAMESPACE
# helm install $KUBE_NAME google_staging/helm/sgdecoding-online-scaled --namespace $NAMESPACE

##### Production #####
# export KUBE_NAME=sgdecoding-online-scaled
# export NAMESPACE=ntuasr-production-google
# gcloud container clusters get-credentials gke-ntu-asr-cluster --zone asia-southeast1-a --project $PROJECT_ID
# kubectl create namespace $NAMESPACE
# kubectl config set-context --current --namespace $NAMESPACE
# kubectl apply -f google_production/secret/run_kubernetes_secret.yaml
# kubectl apply -f google_production/google_pv/  # need to change the ip address of the pvc, need to delete pv when rerunning
# kubectl create secret docker-registry regcred --docker-server=ghcr.io --docker-username=$GITHUB_USERNAME --docker-password=$CR_PAT --docker-email=$GITHUB_EMAIL --namespace $NAMESPACE
# kubectl create secret docker-registry regcred2 --docker-server=registry.gitlab.com --docker-username=$GITLAB_USERNAME --docker-password=$GITLAB_PASSWORD --docker-email=$GITLAB_EMAIL --namespace $NAMESPACE
# helm install $KUBE_NAME google_production/helm/sgdecoding-online-scaled --namespace ntuasr-production-google


##### Combine with argocd #####
# export KUBE_NAME=sgdecoding-online-scaled
# export NAMESPACE=ntuasr-production-google
# gcloud container clusters get-credentials gke-ntu-asr-cluster --zone asia-southeast1-a --project $PROJECT_ID
# kubectl create namespace $NAMESPACE
# kubectl config set-context --current --namespace $NAMESPACE
# kubectl apply -f google_production/secret/run_kubernetes_secret.yaml
# kubectl apply -f google_production/google_pv/  # need to change the ip address of the pvc, need to delete pv when rerunning
# kubectl create secret docker-registry regcred --docker-server=ghcr.io --docker-username=$GITHUB_USERNAME --docker-password=$CR_PAT --docker-email=$GITHUB_EMAIL --namespace $NAMESPACE
# kubectl create secret docker-registry regcred2 --docker-server=registry.gitlab.com --docker-username=$GITLAB_USERNAME --docker-password=$GITLAB_PASSWORD --docker-email=$GITLAB_EMAIL --namespace $NAMESPACE

# helm install $KUBE_NAME argo_production/rollout/google_deployment_helm/helm/sgdecoding-online-scaled --namespace $NAMESPACE
# kubectl apply -f argo_production/ntuasr/application.yaml


### Rollout (install watcher)
# kubectl argo rollouts get rollout sgdecoding-online-scaled-worker-singaporecs-0519nnet3  --watch
# kubectl argo rollouts get rollout sgdecoding-online-scaled-master  --watch
# kubectl-argo-rollouts promote sgdecoding-online-scaled-master 
# kubectl-argo-rollouts promote sgdecoding-online-scaled-worker-singaporecs-0519nnet3 
# kubectl-argo-rollouts promote sgdecoding-online-scaled-worker-singaporemandarin-0519nnet3 

### Teardown
# kubectl delete -f argo_production/ntuasr/application.yaml

##### Staging ######
# export KUBE_NAME=sgdecoding-staging
# export NAMESPACE=ntuasr-staging-google

##### Production #####
export KUBE_NAME=sgdecoding-online-scaled
export NAMESPACE=ntuasr-production-google

# export MASTER_SERVICE="$KUBE_NAME-master"  
export MASTER_SERVICE="$KUBE_NAME-master-preview"  
export MASTER_SERVICE_IP=$(kubectl get svc $MASTER_SERVICE -n $NAMESPACE \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
export MASTER_ENDPOINT=$(kubectl describe svc sgdecoding-online-scaled-master | grep 'Endpoints:')
echo "Master Endpoint:  ${MASTER_ENDPOINT}" 
echo "IP addess of master: ${MASTER_SERVICE_IP}"
python3 client/client_3_ssl.py -u ws://$MASTER_SERVICE_IP/client/ws/speech -r 32000 -t abc --model="SingaporeCS_0519NNET3" client/audio/episode-1-introduction-and-origins.wav


# export PREVIEW_SERVICE="$KUBE_NAME-master-preview"  
# export PREVIEW_SERVICE_IP=$(kubectl get svc $PREVIEW_SERVICE -n $NAMESPACE \
#     --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
# export PREVIEW_ENDPOINT=$(kubectl describe svc sgdecoding-online-scaled-master-preview | grep 'Endpoints:')
# echo "Preview Endpoint:  ${PREVIEW_ENDPOINT}"  #  10.20.7.23:8080
# echo "IP addess of preview: ${PREVIEW_SERVICE_IP}" # 34.87.159.241
# python3 client/client_3_ssl.py -u ws://$PREVIEW_SERVICE_IP/client/ws/speech -r 32000 -t abc --model="SingaporeCS_0519NNET3" client/audio/episode-1-introduction-and-origins.wav


# kubectl-argo-rollouts promote sgdecoding-online-scaled-master


# sgdecoding-online-scaled-master                         LoadBalancer   10.23.240.41    35.240.150.83   80:31715/TCP   4h51m   app.kubernetes.io/instance=sgdecoding-online-scaled,app.kubernetes.io/name=sgdecoding-online-scaled-master,rollouts-pod-template-hash=bc769566b
# sgdecoding-online-scaled-master-preview                 LoadBalancer   10.23.249.124   34.87.159.241   80:30477/TCP   4h51m   app.kubernetes.io/instance=sgdecoding-online-scaled,app.kubernetes.io/name=sgdecoding-online-scaled-master,rollouts-pod-template-hash=bc769566b


##### Teardown #####
# kubectl delete ns ntuasr-staging-google
# kubectl delete ns ntuasr-production-google
# kubectl delete pv fileserver-staging
# kubectl delete pv fileserver-production

