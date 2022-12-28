#Defining Variables:

variable "region" {
    description = "Region where the Infrastructure will be deployed"
    type = string
    default = "eu-west-1"
}


variable "vpc_cidr" {
    description = "CIDR of the VPC"
    type = string
    default = "10.0.0.0/16"
}


variable "app_count" {
  description = "Numbers of apps running at the same time"
  type = number
  default = 1
}


variable "dockerfile_folder" {
  description = "Folder which contains the Dockerfile"
  type        = string
  default = "../application"
}


variable "docker_image_tag" {
  description = "Tag for Dockerimage"
  type        = string
  default     = "latest"
}


variable container_port {
  description = "Port for Flask Application"
  type = number
  default = 5000
}


variable "cluster_name" {
  default     = "ecs_terraform_fargate"
  type        = string
  description = "The name of an ECS cluster"
}