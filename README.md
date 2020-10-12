# terraform_ecs

This is a project to deploy ECS instance and install Jenkins in it using Terraform


Terraform
AWS Instance
Jenkins

Functional Requirements used:
1 VPN
1 subnet
1 EC2 instance 


please add the below add in variable.tf and replace default as mentioned 
**vault can also be used instead of hardcoding.

variable "aws_access_key" {
 type =string
 default= "<your aws access key>"
}  

variable "aws_secret_key" {
 type =string
 default="<your aws secret key>"
}
