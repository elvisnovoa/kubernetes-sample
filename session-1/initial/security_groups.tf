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

# TODO add sg rules for web server

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

# TODO add sg rules for app server
