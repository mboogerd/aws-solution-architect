
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
