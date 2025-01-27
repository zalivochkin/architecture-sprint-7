#!/bin/bash

# https://habr.com/ru/companies/flant/articles/470503/
useradd project_xxx_manager
cd /home/project_xxx_manager || return
openssl genrsa -out project_xxx_manager.key 2048
openssl req -new -key project_xxx_manager.key -out project_xxx_manager.csr -subj "/CN=project_xxx_manager"
openssl x509 -req -in project_xxx_manager.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out project_xxx_manager.crt -days 500
mkdir .certs
mv project_xxx_manager.crt project_xxx_manager.key .certs

useradd project_xxx_user
cd /home/project_xxx_user || return
openssl genrsa -out project_xxx_user.key 2048
openssl req -new -key project_xxx_user.key -out project_xxx_user.csr -subj "/CN=project_xxx_user"
openssl x509 -req -in project_xxx_user.csr -CA ~/.minikube/ca.crt -CAkey ~/.minikube/ca.key -CAcreateserial -out project_xxx_user.crt -days 500
mkdir .certs
mv project_xxx_user.crt project_xxx_user.key .certs

kubectl config set-credentials project_xxx_manager --client-certificate=/home/project_xxx_manager/.certs/project_xxx_manager.crt --client-key=/home/project_xxx_manager/.certs/project_xxx_manager.key
kubectl config set-context project_xxx_manager-context --cluster=kubernetes --user=project_xxx_manager

kubectl config set-credentials project_xxx_user --client-certificate=/home/project_xxx_user/.certs/project_xxx_user.crt --client-key=/home/project_xxx_user/.certs/project_xxx_user.key
kubectl config set-context project_xxx_user-context --cluster=kubernetes --user=project_xxx_user

kubectl create namespace project_xxx
kubectl apply -f project_xxx_roles.yaml
kubectl apply -f project_xxx_bindings.yaml
