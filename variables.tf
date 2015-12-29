variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
  
variable "environment_tag" {
  description = "Role of the ec2 instance, defaults to <DEV>"
  default = "DEV"
}

variable "costcenter_tag" {
  description = "Role of the ec2 instance, defaults to <DEV>"
  default = "DEV"
}
# group our resources
variable "stream_tag" {
  default = "default"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "ap-southeast-2"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        ap-southeast-2 = "ami-811856bb" # amazon linux
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}
