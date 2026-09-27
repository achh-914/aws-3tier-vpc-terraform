# 1. Application Load Balancer in Public Subnets
resource "aws_lb" "external_alb" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name        = "web-app-alb"
    Environment = "Production"
  }
}

# 2. Target Group for Web Application
resource "aws_lb_target_group" "alb_target_group" {
  name     = "web-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-app-tg"
  }
}

# 3. ALB Listener on Port 80
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# 4. AMI Data Source for Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 5. EC2 Launch Template with User Data
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "app-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to 3-Tier Production Architecture Deployed via Terraform!</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "App-Tier-EC2"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 6. Auto Scaling Group across Private App Subnets
resource "aws_autoscaling_group" "app_asg" {
  name                = "app-autoscaling-group"
  target_group_arns   = [aws_lb_target_group.alb_target_group.arn]
  vpc_zone_identifier = [aws_subnet.app_1.id, aws_subnet.app_2.id]

  min_size         = 2
  max_size         = 5
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "App-ASG-Instance"
    propagate_at_launch = true
  }
}
