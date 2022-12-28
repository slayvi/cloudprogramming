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


variable "cpu" {
  description = "CPU the Fargate task should run with."
  type = number
  default = 1024
}


variable "memory" {
  description = "Memory the Fargate task should run with."
  type = number
  default = 2048
}


variable "ecr_name" {
  description = "Name of the Repository."
  type = string 
  default = "mlrepository"
}


variable "ecs_service" {
  description = "Name of ECS Service."
  type = string 
  default = "ml-service"
  
}

variable "container_name" {
  description = "Name of the container."
  type = string 
  default = "ml-app"
  
}

