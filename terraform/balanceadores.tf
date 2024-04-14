resource "aws_lb" "production_app_lb" {
  name               = "production-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1b.id,
    aws_subnet.public_subnet_1c.id
  ]
 

  enable_http2               = true
  idle_timeout               = 60
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "production_app_lb_listener" {
  load_balancer_arn = aws_lb.production_app_lb.arn
  port              = 80
  protocol          = "HTTP"



  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.production_app_target_group.arn
  }
}

resource "aws_lb_target_group" "production_app_target_group" {
  name     = "production-app-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "instance" 
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = "production"
  }
}
