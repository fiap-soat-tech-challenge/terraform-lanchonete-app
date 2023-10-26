resource "aws_lb" "this" {
  name               = "Lanchonete-App-ALB"
  security_groups    = [aws_security_group.alb.id]
  load_balancer_type = "application"

  subnets = [subnet.this["pub_a"].id, subnet.this["pub_b"].id]

  tags = local.tags
}

resource "aws_lb_target_group" "this" {
  name        = "Lanchonete-ALB-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_security_group" "alb" {
  name        = "Lanchonete-ALB-SG"
  description = "Security Group Lanchonete ALB"
  vpc_id      = module.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}
