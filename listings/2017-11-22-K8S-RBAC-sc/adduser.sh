#!/bin/bash
#GREAT thanks to Vincent De Smet from stackoverflow!!!!!!!!
# Add user to k8s 1.5 using service account, no RBAC (unsafe)

if [[ -z "$1" ]] ;then
  echo "usage: $0 <username>"
  exit 1
fi

user=$1
#kubectl create sa ${user}
secret=$(kubectl get sa ${user} -o json | jq -r .secrets[].name)
echo "secret = ${secret}"

kubectl get secret ${secret} -o json | jq -r '.data["ca.crt"]' | base64 -d > ca.crt
user_token=$(kubectl get secret ${secret} -o json | jq -r '.data["token"]' | base64 -d)
echo "token = ${user_token}"

c=`kubectl config current-context`
echo "context = $c"

cluster_name=`kubectl config get-contexts $c | awk '{print $3}' | tail -n 1`
echo "cluster_name= ${cluster_name}"

endpoint=`kubectl config view -o jsonpath="{.clusters[?(@.name == \"${cluster_name}\")].cluster.server}"`
echo "endpoint = ${endpoint}"

# Set up the config
KUBECONFIG=k8s-${user}-conf kubectl config set-cluster ${cluster_name} \
    --embed-certs=true \
    --server=${endpoint} \
    --certificate-authority=./ca.crt
echo ">>>>>>>>>>>>ca.crt"
cat ca.crt
echo "<<<<<<<<<<<<ca.crt"
echo ">>>>>>>>>>>>${user}-setup.sh"
echo kubectl config set-cluster ${cluster_name} \
    --embed-certs=true \
    --server=${endpoint} \
    --certificate-authority=./ca.crt
echo kubectl config set-credentials ${user}-${cluster_name#cluster-} --token=${user_token}
echo kubectl config set-context ${user}-${cluster_name#cluster-} \
    --cluster=${cluster_name} \
    --user=${user}-${cluster_name#cluster-}
echo kubectl config use-context ${user}-${cluster_name#cluster-}
echo "<<<<<<<<<<<<${user}-setup.sh"

echo "...preparing k8s-${user}-conf"
KUBECONFIG=k8s-${user}-conf kubectl config set-credentials ${user}-${cluster_name#cluster-} --token=${user_token}
KUBECONFIG=k8s-${user}-conf kubectl config set-context ${user}-${cluster_name#cluster-} \
    --cluster=${cluster_name} \
    --user=${user}-${cluster_name#cluster-}
KUBECONFIG=k8s-${user}-conf kubectl config use-context ${user}-${cluster_name#cluster-}

#Sample configs for userbind/role

#cat <<EOM > role_${user}.yaml
#
#kind: Role
#apiVersion: rbac.authorization.k8s.io/v1beta1
#metadata:
#  namespace: default
#  name: pod-reader
#rules:
#- apiGroups: [""] # "" indicates the core API group
#  resources: ["pods"]
#  verbs: ["get", "list"]
#
#EOM
#
#cat <<EOM > rolebind_${user}.yaml
#
#kind: RoleBinding
#apiVersion: rbac.authorization.k8s.io/v1beta1
#metadata:
#  name: pod-reader-binding
#  namespace: default
#subjects:
#- kind: ServiceAccount
#  name: ${user}
#  namespace: default
#roleRef:
#  kind: Role
#  name: pod-reader
#  apiGroup: rbac.authorization.k8s.io
#
#EOM
#kubectl create -f role_${user}.yaml
#kubectl create -f rolebind_${user}.yaml

echo "done! Test with: "
echo "KUBECONFIG=k8s-${user}-conf kubectl get no"
