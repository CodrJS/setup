#!/bin/bash

### SETUP ENV VARS
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
K8S_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && dirname "$(pwd)/../k8s/." )
spinner=$SCRIPT_DIR/spinner.sh

namespace=${namespace:-codr}
kubectl=${kubectl:-kubectl}
helm=${helm:-helm}

$kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml 
$kubectl apply -f $K8S_DIR/dev-ingress.yaml -n $namespace
