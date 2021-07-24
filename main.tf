terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

# Create a VPC
resource "aws_vpc" "vpc_sa_as" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = "Education - AWS Solution Architect Associate"
  }
}

# Get the route table for the VPC
data "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.vpc_sa_as.id
  # route_table_id = "rtb-00f5e87a0eb339103"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_sa_as.id

  tags = {
    Name = "main"
  }
}

# And add a rule to route public traffic to the internet gateway
resource "aws_route" "r" {
  route_table_id         = data.aws_route_table.main_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
  depends_on             = [data.aws_route_table.main_rt]
}

# Private availability zones mapped subnets
resource "aws_subnet" "pub_subnet_a" {
  vpc_id                  = aws_vpc.vpc_sa_as.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Private subnet A"
  }
}

resource "aws_subnet" "pub_subnet_b" {
  vpc_id                  = aws_vpc.vpc_sa_as.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Private subnet B"
  }
}

resource "aws_subnet" "pub_subnet_c" {
  vpc_id                  = aws_vpc.vpc_sa_as.id
  cidr_block              = "10.0.32.0/20"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Private subnet C"
  }
}

# Reference the standard AWS image
data "aws_ami" "aws_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Security Groups

# Web security group (Inbound HTTP and HTTPS)
resource "aws_security_group_rule" "allow_tls" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_inbound_web.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_inbound_web.id
}

resource "aws_security_group" "allow_inbound_web" {
  name        = "allow_inbound_web"
  description = "Allow all HTTP and HTTPS/TLS traffic"
  vpc_id      = aws_vpc.vpc_sa_as.id
  tags = {
    Name = "Allow inbound HTTP(S)"
  }
}

# Inbound ICMP
resource "aws_security_group_rule" "allow_inbound_icmp" {
  type = "ingress"
  # https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml#icmp-parameters-types
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_inbound_icmp.id
}

resource "aws_security_group" "allow_inbound_icmp" {
  name        = "allow_inbound_icmp"
  description = "Allow inbound ICMP traffic"
  vpc_id      = aws_vpc.vpc_sa_as.id
  tags = {
    Name = "Allow inbound ICMP"
  }
}

resource "aws_security_group_rule" "allow_inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_inbound_ssh.id
}
resource "aws_security_group" "allow_inbound_ssh" {
  name        = "allow_inbound_ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = aws_vpc.vpc_sa_as.id
  tags = {
    Name = "Allow inbound SSH"
  }
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_all_outbound.id
}

resource "aws_security_group" "allow_all_outbound" {
  name        = "allow_all_outbound"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.vpc_sa_as.id
  tags = {
    Name = "Allow all outbound traffic"
  }
}

# Create a network interface 
# resource "aws_network_interface" "eni_1" {
#   subnet_id       = aws_subnet.pub_subnet_a.id
#   private_ips     = ["10.0.0.50"]
#   security_groups = [aws_security_group.allow_inbound_icmp.id, aws_security_group.allow_inbound_ssh.id, aws_security_group.allow_inbound_web.id, aws_security_group.allow_all_outbound.id]

#   # can't attach as first device because an instance automatically creates an ENI
#   # attachment {
#   #   instance     = aws_instance.instance_test.id
#   #   device_index = 0
#   # }

#   tags = {
#     Name = "primary_network_interface"
#   }
# }

# My key pair
resource "aws_key_pair" "merlijn_kp" {
  key_name   = "merlijn-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDuWS7JHy4uZNNIQ9HNz3TBwCwc4P2QEddIffErVimq6payfDg+hJcQXA++HYIGuBA7pUkts6404ftkaEowwIkAjBlN053iW/NGiX/65WmfzmHPE+k3DQ6SoO+VehV+AzAMFQxkKDKwvIRw7NjXkR8p/YjzCHlDw2jw98/XEQmUVvQb0PeOLpG33cJyN7bAJQuuGAM88wnesiVt3VryfiLWhfJQsj1fPEs/RaIA7h3kCXzEsZ1pPvPZePhBDO/FqehVZYJuvNrUOSBy3LuYnqMG9qIGx5f0C3wcI0EunR0KSdpKqYk7gXL0Gers3ILpNhoxijCZQVjDfK4OGeab/Ysjh0u0Ar9LQ/bg3SWcUMTBxf/eariFhX7Qt5Y4xHUR+xGDlP4LJJEqsjs7f4PXdEtu4xIPDBfHAMSc2QCkR/NgZVTfCQhAo5zywdWlIxpg9KdoIEUTjtKWkKjo0bBQWk4xP1gbrH4NbgvnkomK7B06I9OWGPPmAZeSkwjSEy/j97pfOwEdvvK1wrkJTO2CneM3uOiNI6Hlp5YxO+c/tvFSHfQScRXTWTDvXNXzsFHweukzWf/00pkR6UgNibcbpn1uCmSXasztVKUSQ+EGIfuPLrOQD8ND9WCEBNbUkN99W3dlL7LJ6M8xSyxynDyncSmgvFxVVgLcGvVUhTAK0TjD4w== mlboogerd@gmail.com"
}

# Just a t2 micro instance to be free tier eligible
resource "aws_instance" "instance_test" {
  ami           = data.aws_ami.aws_linux_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.merlijn_kp.key_name

  subnet_id              = aws_subnet.pub_subnet_a.id
  vpc_security_group_ids = [aws_security_group.allow_inbound_icmp.id, aws_security_group.allow_inbound_ssh.id, aws_security_group.allow_inbound_ssh.id, aws_security_group.allow_all_outbound.id]

  # Seems better to let assignment be regulated via aws_network_interface
  # this means that the instance can be created independent of the eni existence
  # Unfortunately, then it cannot be added as first device as without any
  # network_interface clause, AWS (or Terraform) still creates a default one
  # network_interface {
  #   network_interface_id = aws_network_interface.eni_1.id
  #   device_index         = 0
  # }

  tags = {
    Name = "My Test Instance"
  }
}
