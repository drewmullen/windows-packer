variable "vpc_id" {
  description = "VPC ID for the infrastructure"
  type        = string
}

variable "lb_subnet_ids" {
  description = "List of Subnet IDs for the Load Balancer"
  type        = list(string)
}

variable "instance_subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "key_name" {
  description = "Key pair name for accessing the EC2 instance"
  type        = string
}

variable "lb_source_cidr_allow" {
  description = "Source cidr IPv4 range allowed to hit the load balancer"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ami_name_prefix" {
  description = "Pre-fix latest AMI name"
  type        = string
}