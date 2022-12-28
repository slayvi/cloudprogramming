# Creating Ressource Application Load Balancer
resource "aws_lb" "default" {
  name            = "ml-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}


# Creating Security Group for ALB
resource "aws_security_group" "lb" {
  name        = "alb-security-group"
  vpc_id      = aws_vpc.default.id

# Ingress TCP only:
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

# Egress All:
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Creating Target Group for ALB
resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"
}


# Defining Listener for ALB 
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }
}