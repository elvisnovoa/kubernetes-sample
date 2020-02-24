# Template for Tomcat initialization script
data "template_file" "user_data_app" {
  template = file("./templates/userdata-app.sh")
}

# App server launch config
resource "aws_launch_configuration" "app_lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix   = "${var.environment}-app-lc-"
  image_id      = data.aws_ami.aws_linux.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.app_sg.id]

  user_data = data.template_file.user_data_app.rendered
  key_name  = var.key_name
}

# Autoscale Tomcat instances
resource "aws_autoscaling_group" "app_asg" {
  depends_on = [aws_nat_gateway.nat]

  max_size         = 2
  min_size         = 1
  desired_capacity = 2

  name_prefix          = "${aws_launch_configuration.app_lc.name}-"
  vpc_zone_identifier  = aws_subnet.private.*.id
  launch_configuration = aws_launch_configuration.app_lc.id
  target_group_arns    = [aws_alb_target_group.app_tg.id]

  tags = [
    {
      key                 = "Name"
      value               = "app"
      propagate_at_launch = "true"
    },
  ]
}

# Target group for Load Balancer
resource "aws_alb_target_group" "app_tg" {
  name     = "app-tg"
  port     = "8080"
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = {
    Name = "app-tg"
  }
}

# Tomcat Load Balancer
resource "aws_alb" "app_alb" {
  name            = "app-alb"
  security_groups = [aws_security_group.app_sg.id]
  subnets         = aws_subnet.private.*.id
  internal        = true

  tags = {
    Name = "app-alb"
  }
}

# Tomcat Load Balancer listener
resource "aws_alb_listener" "app_alb_listener" {
  load_balancer_arn = aws_alb.app_alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app_tg.arn
    type             = "forward"
  }
}

