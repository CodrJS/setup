#!/bin/bash

### SETUP ENV VARS
K8S_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && dirname "$(pwd)/../k8s/." )

env=${namespace:-local}
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

$kubectl delete -f $K8S_DIR/local-ingress.yaml -n $namespace
$kubectl delete all --all -n $namespace
$kubectl delete secrets --all -n $namespace
$kubectl delete configmaps --all -n $namespace

$kubectl delete clusterrole -n nginx-ingress
$kubectl delete clusterrolebinding -n nginx-ingress

$kubectl delete namespace $namespace
