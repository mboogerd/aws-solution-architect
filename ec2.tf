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

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_admin_instance_profile.name
  tags = {
    Name = "My Test Instance"
  }
}
