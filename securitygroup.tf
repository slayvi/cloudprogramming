

# Creating Security Group for ALB
resource "aws_security_group" "alb" {
  name   = "${var.alb_name}-securtiy-group"
  vpc_id = aws_vpc.default.id

  # Ingress TCP only:
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress All:
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




# Create Security Group for Task:
resource "aws_security_group" "task" {
  name   = "task-securtiy-group"
  vpc_id = aws_vpc.default.id

  # Ingress only Container Port:
  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.alb.id]
  }

  # Egress All:
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

