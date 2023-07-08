#!/bin/bash

### SETUP ENV VARS
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
K8S_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && dirname "$(pwd)/../k8s/." )
LOCAL_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && dirname "$(pwd)/../local/." )
spinner=$SCRIPT_DIR/spinner.sh

env=${env:-local}
kubectl=${kubectl:-kubectl}
helm=${helm:-helm}

while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare $param="$2"
    # echo $1 $2 // Optional to see the parameter:value result
  fi
  shift
done

namespace=codr-$env

### INIT FUNCTIONS
function info() {
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
  echo -e "${BLUE}INFO:${NC} $@"
}
function error() {
  BLUE='\033[0;31m'
  NC='\033[0m' # No Color
  echo -e "${BLUE}ERROR:${NC} $@"
}
function warning() {
  BLUE='\033[1;33m'
  NC='\033[0m' # No Color
  echo -e "${BLUE}WARNING:${NC} $@"
}

function clearLine() {
  tput rc
  tput ed
}

function waitForResponse() {
  info Waiting for "$1" to respond with status 200
  while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $1)" != "200" ]];
  do sleep 0.5
  done
}

if [[ "$(nslookup codr.local | grep 'Address: 127.0.0.1')" == "Address: 127.0.0.1" ]]; then 
  info Creating namespace
  $kubectl create namespace $namespace

  info Setting up local ingress
  $kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml
  $kubectl apply -f $K8S_DIR/local-ingress.yaml -n $namespace

  info Setting up local helm repo
  $kubectl apply -f $K8S_DIR/clients/helm.yaml -n $namespace
  $kubectl wait --for=condition=ready pod -l app=codr-client-helm -n $namespace

  waitForResponse helm.codr.local/index.yaml

  info Installing helm repo
  $helm repo add codr http://helm.codr.local

  info Setting up secrets
  # $kubectl apply -f $LOCAL_DIR/kafka-user.yaml -n $namespace
  $kubectl apply -f $LOCAL_DIR/ses-secret.yaml -n $namespace
  $kubectl apply -f $LOCAL_DIR/ghcr-config.yaml -n $namespace

  info Setting up shared configuration
  $kubectl apply -f $LOCAL_DIR/shared-config.yaml -n $namespace

  info Setting up Apache Kafka
  $helm install kafka -f $K8S_DIR/config/kafka.yaml bitnami/kafka -n $namespace
  $helm install schema-registry -f $K8S_DIR/config/schema-registry.yaml codr/schema-registry -n $namespace

  info Setting up user domain services
  $kubectl apply -f $K8S_DIR/services/user/user.yaml -n $namespace
  $kubectl apply -f $K8S_DIR/services/user/profile.yaml -n $namespace
  $kubectl apply -f $K8S_DIR/services/user/session.yaml -n $namespace
  $kubectl apply -f $K8S_DIR/services/user/usergroup.yaml -n $namespace
  $kubectl apply -f $K8S_DIR/services/user/auth.yaml -n $namespace

  info Setting up web clients
  $helm install client-kafka -f $K8S_DIR/config/client-kafka.yaml codr/client-kafka -n $namespace
  $kubectl apply -f $K8S_DIR/clients/design.yaml -n $namespace
  $kubectl apply -f $K8S_DIR/clients/docs.yaml -n $namespace
  $kubectl apply -f $K8S_DIR/clients/web.yaml -n $namespace

  echo
  info View your local instance at: http://codr.local
  echo
else
  error Ensure the following local dns record exists!
  error
  error "\tWindows:\tC:\\Windows\\System32\\drivers\\\etc\\hosts"
  error "\tUnix:\t\t/etc/hosts"
  error
  error DNS Record:
  error "\t127.0.0.1\tcodr.local\tdocs.codr.local\tkafka.codr.local\tapi.codr.local\thelm.codr.local\tdesign.codr.local"
fi