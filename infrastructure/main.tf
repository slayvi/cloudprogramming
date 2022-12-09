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


provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Name = "architect-demo"
    }
  }
}






resource "docker_image" "mlapp1" {
  name = "mlapp1"
  build {
    path = "../src"
    #tag  = ["mlapp:latest"]
    build_arg = {
      foo : "mlapp1"
    }
    label = {
      author : "mlapp1"
    }
  }

}
 
variable "benutzernummer123" {
  default = "351938391760"
}

variable "region" {
  default = "eu-west-1"
}


# # Build Docker image and push to ECR from folder: ./example-service-directory
# module "ecr_docker_build" {
#   source = "github.com/onnimonni/terraform-ecr-docker-build-module"

#   # Absolute path into the service which needs to be build
#   dockerfile_folder = "../src"
#   # Tag for the builded Docker image (Defaults to 'latest')
#   docker_image_tag = "development"
  
#   # The region which we will log into with aws-cli
#   aws_region = var.region

#   # ECR repository where we can push
#   ecr_repository_url = "${var.benutzernummer123}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.main.name}"
# }

# resource "docker_image" "mlappimage" {
#   name = "mlappimage"
#   build {
#     path = "../src"
#     tag  = ["mlappimage:latest"]
#     build_arg = {
#       foo : "mlappimage"
#     }
#     label = {
#       author : "Slavka"
#     }
#   }
# }

# # Start a container
# resource "docker_container" "mlappcontainer" {
#   name  = "ecrrepomain"
#   image = docker_image.mlappimage.image_id
# }

variable path {
  default = "."
  description = "path to build.sh"
}

# # Checks if build folder has changed
# data "external" "build_folder" {
#   program = ["${path.module}/bin/folder_contents.sh", "../src"]
# }


resource "null_resource" "build_and_push" {
  # triggers = {
  #   build_folder_content_md5 = data.external.build_folder.result.md5
  # }

  # See build.sh for more details
  provisioner "local-exec" {
    command = "${var.path}/bin/build.sh ${var.dockerfile_folder} ${aws_ecr_repository.main.repository_url}:${var.docker_image_tag} ${var.region}"
  }
}


variable "dockerfile_folder" {
  type        = string
  description = "This is the folder which contains the Dockerfile"
  default = "../src"
}
variable "docker_image_tag" {
  type        = string
  description = "This is the tag which will be used for the image that you created"
  default     = "latest"
}






resource "aws_ecr_repository" "main" {
  name                 = "ecrrepomain"
  image_tag_mutability = "MUTABLE"
  force_delete = true 
}





variable "app_count" {
  type = number
  default = 3
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = "10.32.0.0/16"
}

resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.default.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.default.id
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


resource "aws_security_group" "lb" {
  name        = "example-alb-security-group"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "default" {
  name            = "example-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "hello_world" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"
}

resource "aws_lb_listener" "hello_world" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world.id
    type             = "forward"
  }
}


resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "arn:aws:iam::351938391760:role/ecsTaskExecutionRole"


  container_definitions = jsonencode([{
    name        = "hello-world-app"
    image       = "${aws_ecr_repository.main.repository_url}:latest" 
    essential   = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 5000 #var.container_port
      hostPort      = 5000 #var.container_port
      ephemeral_storage = 512
    }]
    
    
    
  }])
}


resource "aws_security_group" "hello_world_task" {
  name        = "example-task-security-group"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol        = "tcp"
    from_port       = 5000
    to_port         = 5000
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_cluster" "main" {
  name = "example-cluster"
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.hello_world_task.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_world.id
    container_name   = "hello-world-app"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.hello_world]
}

output "load_balancer_ip" {
  value = aws_lb.default.dns_name
}







resource "aws_appautoscaling_target" "dev_to_target" {
  max_capacity = 5
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.hello_world.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory" {
  name               = "dev-to-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dev_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dev_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
  }
}

resource "aws_appautoscaling_policy" "dev_to_cpu" {
  name = "dev-to-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.dev_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.dev_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}