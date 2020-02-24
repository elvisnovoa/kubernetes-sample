# Template for Apache initialization script
data "template_file" "user_data_web" {
  template = "${file("./templates/userdata-web.sh")}"

  vars = {
    app_lb = "${aws_alb.app_alb.dns_name}"
  }
}

# HTTP server launch config
resource "aws_launch_configuration" "web_lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.environment}-web-lc-"
  image_id = "${data.aws_ami.aws_linux.id}"
  instance_type = "t2.micro"

  security_groups = [ "${aws_security_group.web_sg.id}" ]

  user_data = "${data.template_file.user_data_web.rendered}"
  key_name = "${var.key_name}"
  associate_public_ip_address = true
}

# Autoscale Apache instances
resource "aws_autoscaling_group" "web_asg" {
  max_size = 2
  min_size = 1
  desired_capacity = 2

  name_prefix = "${aws_launch_configuration.web_lc.name}-"
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]
  launch_configuration = "${aws_launch_configuration.web_lc.id}"
  target_group_arns = [ "${aws_alb_target_group.web_tg.id}" ]

  tags = [
    {
      key = "Name"
      value = "web"
      propagate_at_launch = "true"
    }
  ]
}

# Target group for Load Balancer
resource "aws_alb_target_group" "web_tg" {
  name = "web-tg"
  port = "80"
  protocol = "HTTP"
  vpc_id = "${aws_vpc.example.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags {
    Name = "web-tg"
  }
}

# Apache Load Balancer
resource "aws_alb" "web_alb" {
  name            = "web-alb"
  security_groups = [ "${aws_security_group.web_sg.id}" ]
  subnets         = ["${aws_subnet.public.*.id}"]

  tags {
    Name = "web-alb"
  }
}

# Apache Load Balancer listener
resource "aws_alb_listener" "web_alb_listener" {
  load_balancer_arn = "${aws_alb.web_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.web_tg.arn}"
    type             = "forward"
  }
}