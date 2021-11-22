#bin/bash
#set -x
resource_group_name="taulant_merkato"
cluster_name="merkato-aks"
REG1="^(https|git)"
#REG2="*[^0-9]*"
# make sure terraform CLI is installed
terraform

# format the tf files
terraform fmt

# initialize terraform Azure modules
terraform init

# validate the template
terraform validate


# apply the infra changes

terraform apply -auto-approve

#sleep 4m
#Connecting to aks cluster

az account set --subscription d76100e8-9e78-401e-83b2-4ab9965307f7

az aks get-credentials --resource-group $resource_group_name --name $cluster_name

echo "Plase write root password"
sudo snap install kubectl --classic

#bash deploymet_ingress.sh

#Cloning git repository

echo " ######### Please write git repository as the first argumet ########"
read a

 git clone "$a"
 if [ $? -eq 1 ]
 then
 echo "cannot clone"
 exit 1
 fi
 echo "Deploying backend ...."

 find . -name " backend-deployment.yaml"
 if [ $? -eq 1 ]
 then
 echo "Can not apply kubectl"
 exit 2
 else

 kubectl apply   -f $(find . -name "backend-deployment.yaml")
fi
echo "Deploying frontend .... "

find . -name "frontend-deployment.yaml"
 if [ $? -eq 1 ]
 then
 echo "Can not apply kubectl"
 exit 2
 else

 kubectl apply   -f $(find . -name "frontend-deployment.yaml")
fi
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
if [ $? -eq 0 ]
then
helm install nginx-ingress ingress-nginx/ingress-nginx
fi
echo "Deploying ingress ..."

find . -name "ingress.yaml"
 if [ $? -eq 1 ]
 then
 echo "Can not apply kubectl"
 exit 2
 else

 kubectl apply   -f $(find . -name "ingress.yaml")
fi

