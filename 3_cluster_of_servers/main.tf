terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_launch_configuration" "lc_example" {
    image_id = "ami-07d8796a2b0f8d29c"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    # Required when using a launch configuration with an auto scaling group
    # see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "asg_example" {
    launch_configuration = aws_launch_configuration.lc_example.name
    vpc_zone_identifier = data.aws_subnets.default.ids

    target_group_arns = [aws_lb_target_group.default.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform_asg_example"
        propagate_at_launch = true
    }
}

resource "aws_lb_target_group" "default" {
    name = "example-target-group"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb" "loadbalancer_example" {
    name = "terraform-lb-example"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.loadbalancer.id]
}

resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.loadbalancer_example.arn
    port = 80
    protocol = "HTTP"
    
    # By default return a simple 404 page
    default_action {
      type = "fixed-response"

      fixed_response {
          content_type = "text/plain"
          message_body = "404: page not found"
          status_code = 404
      }
    }
}

resource "aws_lb_listener_rule" "default_listener_rule" {
    listener_arn = aws_lb_listener.http_listener.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.default.arn
    }
}
resource "aws_security_group" "instance" {

  name = var.security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "loadbalancer" {
    name = "loadbalancer_sg"

    # Allow inbound HTTP requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow all outbound requests
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "The from and to port for our webserver"
    type = number
    default = 8080
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance"
}

output "loadbalancer_dns_name" {
    value = aws_lb.loadbalancer_example.dns_name
    description = "The public dns name for the loadbalancer"
}