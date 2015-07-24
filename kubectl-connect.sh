#/bin/sh

KUBECTL_API_SERVER=$(terraform output -state=terraform/terraform.tfstate master-ip)

ssh -f -nNT -L 8080:127.0.0.1:8080 core@$KUBECTL_API_SERVER
