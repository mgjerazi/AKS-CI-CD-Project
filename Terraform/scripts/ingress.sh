#bin/bash
REG1="^(https|git)"
#REG2="*[^0-9]*"
if ! [ $# -eq 2 ]
then
 echo "Please write two argument"
 exit 1
 if ! [ $1 =~ $REG1 ]
 then
 echo "Please write a git repository"
 exit 2
 fi
fi
if ! [[ $1 =~ $REG1 ]] && [[ "$2" == *[^0-9]* ]]
then
 echo "Please write a git repository as first argumet"
else
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
if [ $? -eq 0 ]
then
helm install nginx-ingress ingress-nginx/ingress-nginx
fi
 git clone "$1"
 if [ $? -eq 1 ]
 then
 echo "cannot clone"
 exit 1
 fi
 find . -name "ingress.yaml"
 if [ $? -eq 1 ]
 then
 echo "Can not apply kubectl"
 exit 2
 else

 kubectl apply   -f $(find . -name "ingress.yaml")
fi
fi