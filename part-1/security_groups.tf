# Web server security group
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.example.id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "web_http_ingress" {
  security_group_id = aws_security_group.web_sg.id

  from_port   = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  to_port     = 80
  type        = "ingress"
}

resource "aws_security_group_rule" "web_self_ingress" {
  security_group_id = aws_security_group.web_sg.id

  from_port = 0
  protocol  = "tcp"
  to_port   = 65535
  type      = "ingress"
  self      = true
}

resource "aws_security_group_rule" "web_ssh_ingress" {
  security_group_id = aws_security_group.web_sg.id

  from_port   = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  to_port     = 22
  type        = "ingress"
}

# App server security group
resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.example.id

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "app_http_ingress" {
  security_group_id = aws_security_group.app_sg.id

  from_port   = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  to_port     = 8080
  type        = "ingress"
}

resource "aws_security_group_rule" "app_self_ingress" {
  security_group_id = aws_security_group.app_sg.id

  from_port = 0
  protocol  = "tcp"
  to_port   = 65535
  type      = "ingress"
  self      = true
}

resource "aws_security_group_rule" "app_ssh_ingress" {
  security_group_id = aws_security_group.app_sg.id

  from_port   = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  to_port     = 22
  type        = "ingress"
}

