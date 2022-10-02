# Guide to set up ntuasr-application

## GHCR Set Up
1. Build the image in your local machine `docker build -t ntu-asr-image .`
2. Tag the image `docker tag ntu-asr-image ghcr.io/kaikiat/ntu-asr-image:latest`
3. Create a personal access token for ghcr. Refer to [link](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry)
4. Store this token as CR_PAT 
5. Push to ghcr using `docker push ghcr.io/kaikiat/ntu-asr-image:latest`
6. The image should appear at `https://github.com/kaikiat?tab=packages`

## Google Set Up - Terraform
1. Create a project in gcp 
2. Enable billing and add a billing account
3. Create a gcs bucket `tf-state-prod-12`. Create a folder called `terraform` and another inner folder called `state`
```
terraform {
  backend "gcs" {
    bucket  = "tf-state-prod-12"
    prefix  = "terraform/state"
  }
}
```
4. Run `gcloud auth login` and `gcloud auth application-default login`
5. Set project id using `export PROJECT_ID=your-project-id`
6. Remove .terraform folder
7. Provision gcp resources using Terraform
```
# Terraform will set up application resources
cd Terraform_google || exit
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```
8. Set up iam roles
```
gcloud iam roles create Terraform_role \
  --file=Terraform_role.yaml \
  --project $PROJECT_ID
```
9. Bind policies
```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="projects/${PROJECT_ID}/roles/Terraform_role"
```

## Google Set Up - Filestore 

1. Upload model to Google File Store
 - Go to Gcloud console **Compute Engine > VM instances** and click one of the VMs
 - Get the code to ssh to the VM
 - ssh to the VM using a new terminal window
 - Run the following to mount the filestore onto the VM
``` 
 mkdir mnt 
 sudo mount <filstore ip>:/<filestore path> <mount directory>
 # Example: sudo mount 10.179.74.18:/modelshare mnt
 sudo chmod go+rw mnt
 pwd
```
 - Keep the output from the pwd command
 - Upload the models by running the following in our project root directory:
```
gcloud compute scp models/SingaporeCS_0519NNET3 <VM_ID>:<output_from_pwd> --project=<PROJECT_ID> --zone=asia-southeast1-a --recurse
gcloud compute scp models/SingaporeMandarin_0519NNET3 <VM_ID>:<output_from_pwd> --project=<PROJECT_ID> --zone=asia-southeast1-a --recurse
# Example:
gcloud compute scp models/SingaporeCS_0519NNET3 gke-gke-ntu-asr-clus-ntu-asr-node-poo-3196fc90-f9l9:/home/kaikiat/mnt --project=cube-11 --zone=asia-southeast1-a --recurse
 ```

 > Note: VM_ID looks something like this gke-gke-ntu-asr-clus-ntu-asr-node-poo-5a093a1f-fcd2


## Google Set Up - GKE Cluster
1. Create a namespace 
```
export KUBE_NAME=sgdecoding-online-scaled
export NAMESPACE=ntuasr-production-google
gcloud container clusters get-credentials gke-ntu-asr-cluster --zone asia-southeast1-a --project $PROJECT_ID
kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace $NAMESPACE
```
2. Apply the secrets.yaml and the pv claims. Note: Remember to change the IP address of the file store. Now run 
```
kubectl apply -f secret/run_kubernetes_secret.yaml
kubectl apply -f google_pv/  # need to change the ip address of the pvc, need to delete pv when rerunning
```
3. Create docker secrets
```
kubectl create secret docker-registry regcred --docker-server=ghcr.io --docker-username=$GITHUB_USERNAME --docker-password=$CR_PAT --docker-email=$GITHUB_EMAIL --namespace $NAMESPACE
kubectl create secret docker-registry regcred2 --docker-server=registry.gitlab.com --docker-username=$GITLAB_USERNAME --docker-password=$GITLAB_PASSWORD --docker-email=$GITLAB_EMAIL --namespace $NAMESPACE
```
## Argo CD Set Up
1. Install argocd `brew install argocd`
2. Create argocd namespace `kubectl create namespace argocd`
3. Apply manifests files `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`
4. Port-forward argocd-server using `kubectl port-forward svc/argocd-server -n argocd 8080:443` in another terminal tab.
5. Login through the UI. Password can be obtained from `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo`, the username is `admin`.
6. Login via cli using `argocd login localhost:8080 --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)`
7. Add github ssh key. Refer to github docs if ssh key has not be generated, otherwise run `argocd repo add git@github.com:kaikiat/fyp-cd.git --ssh-private-key-path ~/.ssh/id_rsa`. This can be intepreted as `argocd repo add GITHUB_SSH_URL  --ssh-private-key-path /path/to/ssh/key`, this command with add a github repository to argocd.
8. Verify using `argocd repo list`
9. Apply the manifests file using `kubectl apply -f application.yaml`

## Argo Notifications Set Up
1. Install argo cd notifications `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-notifications/release-1.0/manifests/install.yaml`
2. Setup SMTP server + Slack app beforehand.
3. Add config.yaml which contains the credentials for SMTP server as well as Slack app. `kubectl apply -n argocd -f argo/manifests/config.yaml`
4. Patch the app using
```
# Slack Email
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-succeeded.slack":"#argocd"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-status-unknown.slack":"#argocd"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-failed.slack":"#argocd"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-health-degraded.slack":"#argocd"}}}' --type merge

# SMTP Email
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"recipients.argocd-notifications.argoproj.io":"pohkaikiat98@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-succeeded.gmail":"pohkaikiat98@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-failed.gmail":"pohkaikiat98@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-status-unknown.gmail":"pohkaikiat98@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-health-degraded.gmail":"pohkaikiat98@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-deployed.gmail":"pohkaikiat98@gmail.com"}}}' --type merge
kubectl patch app sgdecoding-online-scaled -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-running.gmail":"pohkaikiat98@gmail.com"}}}' --type merge
``` 
5. By this time, you should also have received an notification from the SMTP server that the application has failed syncing. This is because argorollouts is not configured yet.

## Argo Rollouts Setup
1. Install rollouts plugin using 
```
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-darwin-amd64
chmod +x ./kubectl-argo-rollouts-darwin-amd64
sudo mv ./kubectl-argo-rollouts-darwin-amd64 /usr/local/bin/kubectl-argo-rollouts
```

## Prometheus Installation
1. Run the following commands
```
kubectl create namespace prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus monitoring/manifests/kube-prometheus-stack --namespace prometheus
# Upgrade (If required)
helm upgrade --install prometheus monitoring/manifests/kube-prometheus-stack --namespace prometheus 
```
2. Port forward Prometheus and Grafana
```
kubectl port-forward service/prometheus-kube-prometheus-prometheus 9090 -n prometheus
kubectl port-forward deployment/prometheus-grafana 3000 -n prometheus
```
3. Install service monitor for argo cd `kubectl apply -f monitoring/manifests/service-monitor.yaml -n argocd`
4. Install service monitor for ntuasr application `kubectl apply -f monitoring/manifests/service-monitor-ntuasr.yaml -n ntuasr-production-google`
5. Not sure if this step should take please before configuring blue green rollout ? Run `kubectl apply -f monitoring/manifests/service-monitor-ntuasr-preview.yaml -n ntuasr-production-google`
5. Not sure if this step should take please before configuring blue green rollout ? Run `kubectl apply -f monitoring/manifests/pod-monitor-ntuasr.yaml -n ntuasr-production-google`
6. Only after completing step 1-3, then you can install argo rollouts.

__NOTE: To view metrics exported, run `kubectl port-forward svc/sgdecoding-online-scaled-master 9090`, then go to localhost:8081/metrics__

## Argo Rollouts Installation
1. Create namespace `kubectl create namespace argo-rollouts`
2. Install argo rollouts using `helm install argo-rollouts argo/manifests/argo_rollouts --namespace argo-rollouts`, can be interpreted as `helm install RELEASE_NAME FOLDER`.
3. Install service monitor for argo rollouts `kubectl apply -f monitoring/manifests/service-monitor-argorollouts.yaml -n argo-rollouts`, after installing helm.
4. Resync the app in argocd if needed since argo rollouts is installed. After that you should also receive an email notification
5. Verify that rollout is working by running `kubectl argo rollouts dashboard` to open the rollout web ui. Argo rollout runs at `http://localhost:3100/rollouts`

## Grafana Dashboard Set Up
1. Go to `http://localhost:3000/login` to view the Grafana Web UI. The username is `admin`, the password is `prom-operator`
2. Go to `Dashboard` > `Import` > `Upload JSON file`. Add 2 files `monitoring/configuration/argocd-dashboard.json` and `monitoring/configuration/argorollout-dashboard.json`.

## Analysis
1. Make sure that you have port forwarded argocd, Grafana and Prometheus.
2. Run `kubectl apply -f analysis/manifests/analysis_request.yaml`, set the address as `http://34.87.79.104:9090` pointing it to the external IP address `prometheus-kube-prometheus-prometheus`.
3. Perform a commit and update the version number of the image.
4. Run `python3 suite/canary.py`
5. Run `kubectl get analysisrun <templatename> -o yaml` or can view from argocd ui. Analysis run results should look something like
[![argocd-analysisrun.png](https://i.postimg.cc/wvN7WZVL/argocd-analysisrun.png)](https://postimg.cc/9RWm0xsQ)

## ArgoCD image uploader
1. Run `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml`
2. Set debug level 
```
kubectl patch configmap/argocd-image-updater-config \
  -n argocd \
  --type merge \
  -p '{"data":{"log.level":"debug"}}'
```
3. Add config files
```
kubectl patch configmap/argocd-image-updater-config --patch-file image_uploader/argocd-image-updater-config.yaml -n argocd
kubectl apply -f image_uploader/secrets.yaml
```
4. Make sure that application.yaml follows this format
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: ntuasr=ghcr.io/kaikiat/python-docker:latest
    argocd-image-updater.argoproj.io/ntuasr.update-strategy: latest # Needed ?
    argocd-image-updater.argoproj.io/write-back-method: git
    argocd-image-updater.argoproj.io/git-branch: main
```
4. Point 4 is working. Use this instead 
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: ntuasr=ghcr.io/kaikiat/python-docker
    argocd-image-updater.argoproj.io/write-back-method: git
    argocd-image-updater.argoproj.io/git-branch: main:image-updater{{range .Images}}-{{.Name}}-{{.NewTag}}{{end}}
```
5. Helm chart need to follow the format below
```
image:
  repository: ghcr.io/kaikiat/python-docker
  tag: 0.0.1
  pullPolicy: Always
```
6. Whenever you make a change to argo image updater, restart the deployment using `kubectl -n argocd rollout restart deployment argocd-image-updater`
7. Follow the logs using `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f`
8. When a new image is pushed to ghcr, the logs should show information similar to this
```
time="2022-09-01T13:46:12Z" level=info msg="git checkout --force main" dir=/tmp/git-sgdecoding-online-scaled2528829494 execID=e24d1
time="2022-09-01T13:46:13Z" level=info msg=Trace args="[git checkout --force main]" dir=/tmp/git-sgdecoding-online-scaled2528829494 operation_name="exec git" time_ms=811.638547
time="2022-09-01T13:46:13Z" level=info msg="git clean -fdx" dir=/tmp/git-sgdecoding-online-scaled2528829494 execID=f9339
time="2022-09-01T13:46:13Z" level=info msg=Trace args="[git clean -fdx]" dir=/tmp/git-sgdecoding-online-scaled2528829494 operation_name="exec git" time_ms=14.616689000000001
time="2022-09-01T13:46:13Z" level=debug msg="target parameter file and marshaled data are the same, skipping commit." application=sgdecoding-online-scaled
time="2022-09-01T13:46:13Z" level=info msg="Successfully updated the live application spec" application=sgdecoding-online-scaled
time="2022-09-01T13:46:13Z" level=info msg="Processing results: applications=1 images_considered=1 images_skipped=0 images_updated=1 errors=0"
time="2022-09-01T13:48:13Z" level=info msg="Starting image update cycle, considering 1 annotated application(s) for update"
```
## Canary Rollouts
1. Refer to manifest file in  `canary/rollout/google_deployment_helm/helm/sgdecoding-online-scaled`
2. Change the image in the values.yaml and commit to the main branch
3. Run the folllowing commands to view the logs
```
# Original Master Pod (Ensure that there are no erroneous pods)
NAMESPACE=ntuasr-production-google && \
WORKER=$(kubectl get pods --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[0].metadata.name}" -n $NAMESPACE) && \
kubectl logs $WORKER -f -n $NAMESPACE

# Preview Master Pod
NAMESPACE=ntuasr-production-google && \
WORKER=$(kubectl get pods --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[2].metadata.name}" -n $NAMESPACE) && \
kubectl logs $WORKER -f -n $NAMESPACE
```

## BlueGreen Rollouts
1. Refer to manifest file in  `blue_green/rollout/google_deployment_helm/helm/sgdecoding-online-scaled`
2. Delete existing app in argocd using `argocd app delete sgdecoding-online-scaled` (Is this needed ?)
3. In `application.yaml` under `spec.source.path` change the path to `path: blue_green/rollout/google_deployment_helm/helm/sgdecoding-online-scaled`
4. In the secrets define `MASTER=sgdecoding-online-scaled-master`
5. For the next git commit, change the value to `MASTER=sgdecoding-online-scaled-master-preview` for both secrets in the `secrets.yaml`. Also, change to a new image.
6. Change the image in the values.yaml and commit to the main branch
7. Verify that the preview service is created using `kubectl get svc`
8. The rollout will be paused by default, to test the preview service, toggle between `$KUBE_NAME-master-preview` and `$KUBE_NAME-master"` in `google_initial_setup.sh`.
9. Meanwhile, open 2 terminal to view the logs for the original master pod and the preview master pod.

## Promethues and Grafana in-depth
1. Go to `Explore` in the Grafana UI.
2. Input the following parameters as seen in the figure below

[![grafana-ui-querry-with-legend.png](https://i.postimg.cc/Bnn79y5Z/grafana-ui-querry-with-legend.png)](https://postimg.cc/Vd2WXKH2)

3. For canary rollouts, use CLI
<!-- 3. For canary rollouts, execute the following querries 
```
# Compare requests received
number_of_request_receive_by_master_total{pod="sgdecoding-online-scaled-master-7858cccfdb-5kjg4"}
number_of_request_receive_by_master_total{pod="sgdecoding-online-scaled-master-7858cccfdb-5kjg4"}
``` -->
4. For blue green rollouts, execute the following querries
```
# For successful requests
number_of_request_receive_by_master_total{service="sgdecoding-online-scaled-master-preview"}
number_of_request_receive_by_master_total{service="sgdecoding-online-scaled-master"}

# For failed requests
number_of_request_reject_total{service="sgdecoding-online-scaled-master"}
number_of_request_reject_total{service="sgdecoding-online-scaled-master-preview"}
```


## Others  
1. Uninstall prometheus charts [https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#uninstall-helm-chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#uninstall-helm-chart)

## Shortcuts
1. kubectl config set-context --help, set context using `kubectl config use-context CONTEXT_NAME`
2. Run
```
for p in $(kubectl get pods | grep Terminating | awk '{print $1}'); do kubectl delete pod $p --grace-period=0 --force;done
for p in $(kubectl get pods | grep Error | awk '{print $1}'); do kubectl delete pod $p --grace-period=0 --force;done
for p in $(kubectl get pods | grep Completed | awk '{print $1}'); do kubectl delete pod $p --grace-period=0 --force;done
```
3. List context `kubectl config get-contexts`
4. Get argocd app yaml `k get app sgdecoding-online-scaled -n argocd -o yaml`

## Issues
1. Add terraform code here please