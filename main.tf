# Declare Providers AWS and Docker:
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}


# Configure AWS:
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name        = var.name_project
      Author      = var.name_author
      Environment = var.environment
    }
  }
}



