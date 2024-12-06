resource "aws_instance" "windows_iis" {
  ami           = data.aws_ami.windows_iis.id
  instance_type = "t2.medium"
  subnet_id     = var.instance_subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.allow_http.id
  ]

  associate_public_ip_address = false

  tags = {
    Name = "Windows-IIS-Server"
  }
}

data "aws_ami" "windows_iis" {
  most_recent = true
  name_regex  = "^${var.ami_name_prefix}*"
  owners      = ["self"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id            = aws_security_group.allow_http.id
  referenced_security_group_id = aws_security_group.alb_http.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb" "web_alb" {
  name               = "windows-iis-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.lb_subnet_ids
  security_groups = [
    aws_security_group.alb_http.id
  ]
}

resource "aws_security_group" "alb_http" {
  name        = "alb_http"
  description = "Allow HTTP on source CIDR range"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_ipv4" {
  security_group_id = aws_security_group.alb_http.id
  cidr_ipv4         = var.lb_source_cidr_allow
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_all_traffic_ipv4" {
  security_group_id = aws_security_group.alb_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_lb_target_group" "web_tg" {
  name        = "iis-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.windows_iis.id
  port             = 80
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}