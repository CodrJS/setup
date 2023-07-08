#!/bin/bash

### SETUP ENV VARS
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
K8S_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && dirname "$(pwd)/../k8s/." )
spinner=$SCRIPT_DIR/spinner.sh

env=${env:-test}
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

info Setting up secrets
$kubectl apply -f $K8S_DIR/secrets/ses.yaml -n $namespace
info Setting up shared configuration
$kubectl apply -f $K8S_DIR/shared-config.yaml -n $namespace
info Setting up Apache Kafka
$helm install kafka -f $K8S_DIR/kafka/kafka.yaml bitnami/kafka -n $namespace
$kubctl apply -f $K8S_DIR/kafka/schema-registry.yaml -n $namespace
$kubctl apply -f $K8S_DIR/kafka/kafka-ui.yaml -n $namespace
info Setting up user domain services
$kubectl apply -f $K8S_DIR/services/user/user.yaml -n $namespace
$kubectl apply -f $K8S_DIR/services/user/profile.yaml -n $namespace
$kubectl apply -f $K8S_DIR/services/user/session.yaml -n $namespace
$kubectl apply -f $K8S_DIR/services/user/usergroup.yaml -n $namespace
$kubectl apply -f $K8S_DIR/services/user/auth.yaml -n $namespace
info Setting up ingress
$kubectl apply -f $K8S_DIR/traefik-ingress.yaml -n $namespace

echo
info Configuration complete!
echo