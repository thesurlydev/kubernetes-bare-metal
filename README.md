# kubernetes-bare-metal

Kubernetes setup for Ubuntu on bare metal.


The intent is to outline the steps necessary to install a multi-node Kubernetes 1.18 cluster on Ubuntu 20.04.

<!--ts-->   
  * [Components](#components)  
  * [Gotchas](#gotchas)
  * [Docker](#docker)
      * [Installation](#installation)
  * [kubectl, kubeadm, kubelet](#kubectl-kubeadm-kubelet)
  * [kubelet service config](#kubelet-service-config)
  * [Disable Swap](#disable-swap)
  * [Install via kubeadm](#install-via-kubeadm)
  * [Troubleshooting kubelet](#troubleshooting-kubelet)
  * [Post Install](#post-install)
  * [Weave](#weave)
  * [Join Additional Nodes (workers)](#join-additional-nodes-workers)
  * [Dashboard](#dashboard)
      * [Create user](#create-user)
      * [Install Dashboard](#install-dashboard)
      * [Start Dashboard Proxy](#start-dashboard-proxy)
      * [Login](#login)
  * [Pulling from Private Docker Registries](#pulling-from-private-docker-registries)
  * [Updating a deployment](#updating-a-deployment)
  * [Get a list of all containers running in all pods in all namespaces](#get-a-list-of-all-containers-running-in-all-pods-in-all-namespaces)
  * [Port forwarding](#port-forwarding)  
  * [Multiple Clusters](#multiple-clusters)
  * [Troubleshooting](#troubleshooting)  

<!-- Added by: shane, at: Mon 30 Mar 2020 09:21:29 AM PDT -->

<!--te-->


## Components

* Ubuntu 20.04 Focal Fossa (development branch)
* Kubernetes 1.18 with cgroups-driver=systemd
* Docker 19.03.8
* Docker Hub Registry
* Weave 2.6.2
* Web UI (kubernetes dashboard)


## Gotchas

* Versions
* Ensuring cgroups-driver for Docker and Kubelet match
* Starting over:
   * kubeadm reset
   * sudo rm -rf /etc/kubernetes
* Making changes to kubelet:
   * systemctl daemon-reload
   * systemctl restart kubelet 


## Docker

### Installation

First, update existing list of packages:
```
sudo apt update
```

Next, install prerequisites:

```
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```
Add the GPG key for the official Docker repository:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`
```
Add the Docker repository to APT sources:
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
```
Update package database with the Docker packages:
```
sudo apt update
```
Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:
```
apt-cache policy docker-ce
```
Now, install:
```
sudo apt install docker-ce
```



Confirm install:
```
sudo systemctl status docker
```
should return somethink like:
```
docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2020-06-19 15:27:09 UTC; 4s ago
     Docs: https://docs.docker.com
 Main PID: 17823 (dockerd)
    Tasks: 22
   CGroup: /system.slice/docker.service
           └─17823 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```           



```
docker version
```

```bash
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b7f0
 Built:             Wed Mar 11 01:25:55 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b7f0
  Built:            Wed Mar 11 01:24:26 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

Update cgroupdriver in `/etc/docker/daemon.json` to use systemd:
```
{
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
```

Restart Docker daemon via:
```
systemctl restart docker
```


Verify Docker cgroup driver via:
```
docker info -f {{.CgroupDriver}}
```

## kubectl, kubeadm, kubelet

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```


```kubectl version -o json```

```json
{
  "clientVersion": {
    "major": "1",
    "minor": "18",
    "gitVersion": "v1.18.0",
    "gitCommit": "9e991415386e4cf155a24b1da15becaa390438d8",
    "gitTreeState": "clean",
    "buildDate": "2020-03-25T14:58:59Z",
    "goVersion": "go1.13.8",
    "compiler": "gc",
    "platform": "linux/amd64"
  },
  "serverVersion": {
    "major": "1",
    "minor": "18",
    "gitVersion": "v1.18.0",
    "gitCommit": "9e991415386e4cf155a24b1da15becaa390438d8",
    "gitTreeState": "clean",
    "buildDate": "2020-03-25T14:50:46Z",
    "goVersion": "go1.13.8",
    "compiler": "gc",
    "platform": "linux/amd64"
  }
}
````

Add the following to `/etc/apt/sources.list` (eoan since focal is not available yet):

```bash
deb [arch=amd64] https://download.docker.com/linux/ubuntu eoan stable
```
Add `/etc/apt/sources.list.d/kubernetes.list` with the following content (xenial is latest available and will still work with latest versions of Ubuntu):
```bash
deb https://apt.kubernetes.io/ kubernetes-xenial main
```

Add gpg key:
```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```


Add the following to `/etc/default/kubelet`:
```bash
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd
```




## kubelet service config

## Disable Swap

```bash
sudo swapoff -a
```

To permanently disable swap (to survive reboot) then remove any **swap** entry from `/etc/fstab`.



## Install via kubeadm

```
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg2
```

Add the following to `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`:

```
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generate at runtime, populatingthe KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably,
# the user should use the .NodeRegistration.KubeletExtraArgs object in the configuration files instead.
# KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

Create dir if it doesn't exist:
```bash
sudo mkdir -p /var/lib/kubelet
```

Add the following to `/var/lib/kubelet/kubeadm-flags.env`:
```
KUBELET_KUBEADM_ARGS="--cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2 --resolv-conf=/run/systemd/resolve/resolv.conf"
```

Install the cluster via:
```sudo kubeadm init -v=6```



## Troubleshooting kubelet

The following are your friends when troubleshooting kubelet startup issues:

Get the status of the kubelet service:
```systemctl status kubelet```

Look at the logs of the kubelet service (scroll to bottom):
```journalctl -xeu kubelet```


## Post Install

```
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


## Weave

Install via:
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

To disable NPS:

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&disable-npc=true"
```


## Join Additional Nodes (workers)

After running `kubeadm init` on the master node, there will be output including something like the below snipper:

```
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.7.40:6443 --token th6npu.fmuxapxjzsx8k7zt \
    --discovery-token-ca-cert-hash sha256:e947ea9db4ef3182ac870618d300c16cac09d6de45c28ffab73b74099f673870
```


## Dashboard

### Create user

Taken from: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

Create a file called `dashboard-adminuser.yaml` with the following content:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard  
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:  
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
- kind: ServiceAccount
  name: admin-user
  namespace: default
```

Use the following to apply/create:

```
kubectl apply -f dashboard-adminuser.yaml
```



### Install Dashboard

```kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc6/aio/deploy/recommended.yaml```

### Start Dashboard Proxy

```kubectl proxy```

### Login

First, get the bearer token via:

```bash
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

Second, visit http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ and login with the bearer token.


## Pulling from Private Docker Registries

In order to all Kubernetes to pull from private Docker registries you need to create a secret with the registry credentials then add the secret to the `default` service account.

```bash
kubectl create secret docker-registry dockerhubregistrykey --docker-server=https://index.docker.io/v1/ --docker-username=digitalsanctum --docker-password=YOUR_PASSWORD --docker-email=shane@digitalsanctum.com
```
```bash
kubectl edit serviceaccounts default
```

Add the following to the file after `secrets`:

```yaml
imagePullSecrets:
- name: dockerhubregistrykey
```
Save the file as `sa.yaml` then update the service account via:

```bash
kubectl replace serviceaccount default -f ./sa.yaml
```

Finally, update deployment.yaml with `imagePullSecrets`:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kgen
  namespace: default
  labels:
    app: kgen
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kgen
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%
      maxSurge: 25%
  revisionHistoryLimit: 10
  progressDeadlineSeconds: 600
  template:
    metadata:
      labels:
        app: kgen
        cluster-name: kubernetes
    spec:
      serviceAccountName: kgen-sa
      imagePullSecrets:
        - name: dockerhubregistrykey
      containers:
        - name: kgen
          image: digitalsanctum/kgen-service:0.1.0
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: local
            - name: POD_NAME
              value: metadata.name
          readinessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 60
            timeoutSeconds: 2
            failureThreshold: 1
            successThreshold: 1
          livenessProbe:
            httpGet:
              path: /actuator/health
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 70
            timeoutSeconds: 5
            failureThreshold: 2
            successThreshold: 1
          resources:
            limits:
              cpu: 500m
              memory: 1Gi
            requests:
              cpu: 250m
              memory: 500Mi
```

## Updating a deployment

First, grab the deployment via:
```bash
kubectl get deployments kgen-service -o yaml > kgen-service-deployment.yaml
```
Second, edit the file as necessary.

Lastly, update the deployment with your changes:
```bash
kubectl replace deployments kgen-service -f ./kgen-service-deployment.yaml
```
-OR-

Just edit the deployment. When it's saved the deployment will be replaced:

```bash
kubectl edit deployments kgen-service
```

## Get a list of all containers running in all pods in all namespaces

```bash
kubectl get pods --all-namespaces -o jsonpath={..image} | tr -s '[[:space:]]' '\n' | sort -u
```

## Port forwarding

Forward one or more local ports to a pod. This command requires the node to have 'socat' installed.

As an example to port forward to an application listening on port `8080`:

```bash
kubectl port-forward deployment/kgen-service 8080
```

## Multiple Clusters

To view the available contexts/clusters:

```
kubectl config get-contexts
```

To switch from one cluster to another:

```
kubectl config use-context kubernetes-admin@kubernetes
```

## Custom Namespaces

```
kubectl get pods -n <custom-namespace>
```

## Scaling your deployments

```
kubectl scale deployment <app-name> --replicas <replica-count>
```

## Zero downtime deployments

The default way to update a running application in Kubernetes is to deploy a new image tag to your Docker registry and then deploy it using:

```
kubectl set image deployment/<app-name>-app <app-name>=<new-image>
```

Using livenessProbes and readinessProbe allows you to tell Kubernetes about the state of your applications, in order to ensure availability of your services. You will need a minimum of 2 replicas for every application if you want to have zero downtime deployment. This is because the rolling upgrade strategy first stops a running replica in order to place a new one. Running only one replica will cause a short downtime during upgrades.

## Troubleshooting



### Deploy Verification

Wait for deploy to complete:
```
kubectl rollout status -n default deployments/springboot-microservice --watch
```
-or-
```
`curl --silent --fail --retry 60 --retry-delay 5 --retry-connrefused --insecure --output /dev/null $ENDPOINT/health`
```



