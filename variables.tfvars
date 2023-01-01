environment = "development"

name_project = "ML-Application"

name_author = "Slavka Fersch"

region = "eu-west-1"

vpc_cidr = "10.0.0.0/16"

count_av_zones = 2

app_count = 1

container_port = 5000

cluster_name = "ml-cluster"

dockerfile_folder = "../application"

cpu = 256

memory = 512

ecr_name = "ml-repository"

ecs_service = "ml-service"

container_name = "ml-container"

docker_image_tag = "latest"

docker_image_name = "aws-ml-app"

alb_name = "lb"