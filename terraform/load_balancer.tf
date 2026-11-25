resource "aws_lb" "alb" {
  name               = "cloud-project-alb"
  load_balancer_type = "application"
  internal           = false
  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
  security_groups = [
    aws_security_group.ALB_SG.id
  ]
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "cloud-project-alb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
  health_check {
    protocol = "HTTP"
    port     = "traffic-port"
    path     = "/health.php"
  }
}

resource "aws_lb_target_group_attachment" "app_ec2" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.app_EC2.id
}

resource "aws_lb_listener" "https_listener" {
  protocol          = "HTTPS"
  port              = 443
  load_balancer_arn = aws_lb.alb.id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
  certificate_arn = aws_acm_certificate.cloudforge.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

resource "aws_lb_listener" "http_listener" {
  protocol          = "HTTP"
  port              = 80
  load_balancer_arn = aws_lb.alb.id

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

