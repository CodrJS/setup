#!/bin/bash

### SETUP ENV VARS
namespace==${namespace:-codr}
kubectl==${kubectl:-kubectl}
helm==${helm:-helm}

while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare $param="$2"
    # echo $1 $2 // Optional to see the parameter:value result
  fi
  shift
done

$kubectl delete MongoDBCommunity --all -n $namespace
$kubectl delete all --all -n $namespace
$kubectl delete secrets --all -n $namespace
$kubectl delete namespace $namespace
