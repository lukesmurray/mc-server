# Defines all variables and their descriptions for mc server on aws.

variable "region" {
  description = "aws region"
}

variable "instance_type" {
  default     = "t3.small"
  description = "ec2 instance type. Recommend t3.small and 1gb of RAM per 10 players."
}

variable "project_tag" {
  default     = "mc_auto"
  description = "resources associated with this project have tag project = <project tag>"
}

variable "aws_public_key" {
  description = "The public key associated with the private key from aws setup. Obtain using > ssh-keygen -y -f key.pem"

}

variable "aws_key_name" {
  description = "The name of the key from aws setup. Obtain using > aws ec2 describe-key-pairs | jq '.KeyPairs[].KeyName'"
}
variable "aws_sec_group_name" {
  description = "The name of the security group"
}

variable "aws_s3_access_name" {
  description = "The name of the s3 access role"
}

variable "bucket_name" {
  description = "The name of the s3 bucket to store data in, including world backups"
}

variable "lambda_password" {
  description = "The password used to log into the lambda function and control the server."
}


