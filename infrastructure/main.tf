# Declare Providers AWS and Docker:
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    docker = {
      source = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}


# Define AWS options:
provider "aws" {
    region = var.region
    default_tags {
        tags = {
        Name = "ML-Application"
        Author = "Slavka Fersch"
        }
    }
}