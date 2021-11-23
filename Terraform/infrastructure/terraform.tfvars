appId    = "ce79ea92-044a-485d-9416-2dde1fffbc11"
password = "XfyvP75eOXx5HnbHItEYP6kVBsti.BwE8q"

/*
STEPS
az login
az ad sp create-for-rbac --skip-assignment
(copy appId and password to terraform.tfvars)
terraform init
terraform validate
terraform apply
terraform destroy
*/