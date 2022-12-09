#!/bin/bash

### SETUP ENV VARS
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
K8S_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && dirname "$(pwd)/../k8s/." )
spinner=$SCRIPT_DIR/spinner.sh

namespace=${namespace:-codr}
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

### INIT FUNCTIONS
function clearLine() {
  tput rc
  tput ed
}

function waitForMongo() {
  while : ; do
    local status=`$kubectl get mongodbcommunity mongodb -n $namespace -o jsonpath="{.status.phase}"`
    sleep 0.2
    [[ $status == "Running" ]] && break;
  done
}

### INSTALL HELM REPOS
$helm repo add mongodb https://mongodb.github.io/helm-charts
$helm install community-operator mongodb/community-operator --namespace $namespace --create-namespace

### GET PASSWORD FOR MONGODB INSTANCE
echo "Please enter an admin password for mongodb"
tput sc
while true; do
  # Read Password
  printf "Password: "
  read -s p1
  clearLine
  printf "Password (confirm): "
  read -s p2
  clearLine
  [ "$p1" = "$p2" ] && break || echo "Please try again"
done
echo
# CREATE PASSWORD SECRET
echo "Creating password"
$kubectl create secret generic admin-password --namespace $namespace --from-literal="password=$p1"

### APPLY MONGODB REPLICASET
echo "Setting up MongoDB replicaset"
$spinner $kubectl apply -f $K8S_DIR/mongodb.yaml --namespace $namespace
echo "Waiting for MongoDB instance to become ready, this make take a few minutes..."
waitForMongo
echo
$spinner $kubectl get mongodbcommunity -n $namespace
echo

tput sc
printf "Would you like to view your MongoDB credentials? (Y/n): "
read q1
case $q1 in
  [Nn]* ) 
    echo "If you wish to view your credentials later, run the following:"
    echo "  $kubectl get secret mongodb-codr-admin -n $namespace -o json | jq -r '.data | with_entries(.value |= @base64d)'"
    ;;
  * )
    $kubectl get secret mongodb-codr-admin -n $namespace -o json | jq -r '.data | with_entries(.value |= @base64d)'
    ;;
esac