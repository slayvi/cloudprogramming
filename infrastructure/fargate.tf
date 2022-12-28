# Create ECR Repository:
resource "aws_ecr_repository" "main" {
  name = "mlrepository"
  force_delete = true
}


# Create ECS Cluster:
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}


# Create Task Definition for Fargate:
resource "aws_ecs_task_definition" "ml_task_def" {
  family                   = "ml-app"  
  network_mode             = "awsvpc" 
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([{
    name        = "ml-app"
    image       = "${aws_ecr_repository.main.repository_url}:${var.docker_image_tag}"  
    essential   = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 5000 
      hostPort      = 5000 
      ephemeral_storage = 512
    }]    
  }])
}


# Create Security Group for Task:
resource "aws_security_group" "ml_sec_group" {
  name        = "ml-task"
  vpc_id      = aws_vpc.default.id

# Ingress only Container Port:
  ingress {
    protocol        = "tcp"
    from_port       = var.container_port 
    to_port         = var.container_port 
    security_groups = [aws_security_group.lb.id]
  }

# Egress All:
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create ECS Service:
resource "aws_ecs_service" "mlservice" {
  name            = "ml-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ml_task_def.arn
  desired_count   = 2
  launch_type     = "FARGATE"

# Assign to security group and private subnets:
  network_configuration {
    security_groups = [aws_security_group.ml_sec_group.id]
    subnets         = aws_subnet.private.*.id
    assign_public_ip = false 

  }

# Assign to load balancer:
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    container_name   = "ml-app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.lb_listener] 
}