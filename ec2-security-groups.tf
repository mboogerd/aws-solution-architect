
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
