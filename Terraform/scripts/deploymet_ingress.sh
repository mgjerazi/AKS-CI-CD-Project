#bin/bash
REG1="^(https|git)"
#REG2="*[^0-9]*"
echo "Please write git repository as the first argumet"
read a

 git clone "$a"
 if [ $? -eq 1 ]
 then
 echo "cannot clone"
 exit 1
 fi
 find . -name "backend-deployment.yaml"
 if [ $? -eq 1 ]
 then
 echo "Can not apply kubectl"
 exit 2
 else

 kubectl apply   -f $(find . -name "backend-deployment.yaml")
fi
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
find . -name "ingress.yaml"
 if [ $? -eq 1 ]
 then
 echo "Can not apply kubectl"
 exit 2
 else

 kubectl apply   -f $(find . -name "ingress.yaml")
fi