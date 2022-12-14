# Server Configuration

This configuration is based on the following hardware and services:

Local machine:
- **OS:** Windows; with WSL2 installed using Ubuntu
- **Platform:** Docker; connected through WSL2 with the additional Kubernetes (K8s) configuation.

Server:
- **OS:** Ubuntu Server 20.04.3
- **Platform:** MicroK8s; installed seperately from OS installation, installed MicroK8s during server creation always tends to cause corruptions and misconfiguration of K8s (at least for me).

## Prerequisites 

In order to run this configuration for Codr, you need to have a Kubernetes (K8s) cluster running. The quickest way of installing K8s locally is through the Docker Desktop application. 

>**Recommendation:** For Windows users, I highly recommend installing WSL2, it allows for development in an Ubuntu environment which makes averything so much easier.

The installation script (`scripts/install.sh`) requires `jq` and `helm3` to be installed, you can install it on debian-based machines via the following command:

### Installing Helm
There are two ways of installing the Helm, both are described below.

```sh
### Via script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Alternatively:
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

```sh
### Via apt-get
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### Installing other packages

```sh
sudo apt-get install -y jq
```

## Running the installation script

By default, the script should work without any additional arguments unless the specific installation of K8s has renamed the commands; such as `microk8s`.

### Arguments:
|Argument|default|description|
|---|---|---|
|--namespace|`codr`|Namespace to install codr to|
|--kubectl|`kubectl`|Alternative command for `kubectl`|
|--helm|`helm`|Alternative command for `helm`|

### Examples:

**Normal installation:**
```sh
chmod +x scripts/*.sh
./scripts/install.sh
kubectl apply -f k8s/codr.yaml 
```

**MicroK8s installation:**
```sh
chmod +x scripts/*.sh
./scripts/install.sh --kubectl "microk8s.kubectl" --helm "microk8s.helm3"
kubectl apply -f k8s/codr.yaml 
```