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
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Education - AWS Solution Architect Associate"
  }
}

# Private availability zones mapped subnets
resource "aws_subnet" "priv_subnet_a" {
  vpc_id            = aws_vpc.vpc_sa_as.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Private subnet A"
  }
}

resource "aws_subnet" "priv_subnet_b" {
  vpc_id            = aws_vpc.vpc_sa_as.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "Private subnet B"
  }
}

resource "aws_subnet" "priv_subnet_c" {
  vpc_id            = aws_vpc.vpc_sa_as.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "eu-central-1c"

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

# Just a t2 micro instance to be free tier eligible
resource "aws_instance" "instance_test" {
  ami           = data.aws_ami.aws_linux_ami.id
  instance_type = "t2.micro"

  tags = {
    Name = "My Test Instance"
  }
}
