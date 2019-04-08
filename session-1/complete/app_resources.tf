# Template for Tomcat initialization script
data "template_file" "user_data_app" {
  template = "${file("./templates/userdata-app.sh")}"
}

# App server launch config
resource "aws_launch_configuration" "app_lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.environment}-app-lc-"
  image_id = "${data.aws_ami.aws_linux.id}"
  instance_type = "t2.micro"

  security_groups = [ "${aws_security_group.app_sg.id}" ]

  user_data = "${data.template_file.user_data_app.rendered}"
  key_name = "${var.key_name}"
}

# Autoscale Tomcat instances
resource "aws_autoscaling_group" "app_asg" {
  max_size = 2
  min_size = 1
  desired_capacity = 2

  name = "app-asg"
  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]
  launch_configuration = "${aws_launch_configuration.app_lc.id}"
  target_group_arns = [ "${aws_alb_target_group.app_tg.id}" ]

  tags = [
    {
      key = "Name"
      value = "app"
      propagate_at_launch = "true"
    }
  ]
}

# Target group for Load Balancer
resource "aws_alb_target_group" "app_tg" {
  name = "app-tg"
  port = "80"
  protocol = "HTTP"
  vpc_id = "${aws_vpc.example.id}"

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

  tags {
    Name = "app-tg"
  }
}

# Tomcat Load Balancer
resource "aws_alb" "app_alb" {
  name            = "app-alb"
  security_groups = [ "${aws_security_group.app_sg.id}" ]
  subnets         = ["${aws_subnet.private.*.id}"]
  internal = true

  tags {
    Name = "app-alb"
  }
}

# Tomcat Load Balancer listener
resource "aws_alb_listener" "app_alb_listener" {
  load_balancer_arn = "${aws_alb.app_alb.arn}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app_tg.arn}"
    type             = "forward"
  }
}

# BONUS: scale elastically
# scale up alarm
resource "aws_autoscaling_policy" "asg_cpu_policy" {
  name                   = "app-cpu-policy"
  autoscaling_group_name = "${aws_autoscaling_group.app_asg.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "90"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_alarm" {
  alarm_name          = "app-cpu-alarm"
  alarm_description   = "app-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUReservation"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "75"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.app_asg.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.asg_cpu_policy.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "app_cpu_policy_scaledown" {
  name                   = "app-cpu-policy-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.app_asg.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_alarm_scaledown" {
  alarm_name          = "app-cpu-alarm-scaledown"
  alarm_description   = "app-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUReservation"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.app_asg.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.app_cpu_policy_scaledown.arn}"]
}
