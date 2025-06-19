variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the new VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "ecs-cluster"
}

variable "service_name" {
  description = "ECS service (and task) name"
  type        = string
  default     = "strapi"
}

variable "container_port" {
  description = "Port your container listens on"
  type        = number
  default     = 1337
}

variable "env_vars" {
  description = "Map of environment variables to set in the ECS container"
  type        = map(string)
  default     = {}
}