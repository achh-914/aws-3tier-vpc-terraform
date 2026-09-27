# 1. Security Group for Web / Public Layer
resource "aws_security_group" "web_sg" {
  name        = "web-tier-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-tier-sg"
  }
}

# 2. Security Group for Application Layer
resource "aws_security_group" "app_sg" {
  name        = "app-tier-sg"
  description = "Allow traffic from Web Tier only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow custom app port from Web SG"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-tier-sg"
  }
}

# 3. Security Group for Database Layer
resource "aws_security_group" "db_sg" {
  name        = "db-tier-sg"
  description = "Allow MySQL traffic from App Tier only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL port from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-tier-sg"
  }
}
