variable "ami_name" {
  type    = string
  default = "Windows-Server-IIS{{timestamp}}"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}
