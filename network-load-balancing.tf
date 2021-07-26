# Reference the standard AWS image
data "aws_ami" "aws_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


variable "user_data" {
  type    = string
  default = <<EOT
#!/bin/bash
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
cd /var/www/html
aws s3 cp s3://mboogerd-test/names.csv ./
aws s3 cp s3://mboogerd-test/index.txt ./
EC2NAME=`cat ./names.csv|sort -R|head -n 1|xargs`
sed "s/INSTANCE/$EC2NAME/" index.txt > index.html
EOT
}

resource "aws_lb" "aws_lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.pub_subnet_a.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.pub_subnet_b.id
  }

  enable_cross_zone_load_balancing = true
  # Will also prevent Terraform from deleting the resource and thus require manual state maintenance after the deployment crashes
  # enable_deletion_protection = true
}

resource "aws_lb_listener" "aws_lb_http" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_target_group.arn
  }
}


resource "aws_lb_target_group" "http_target_group" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc_sa_as.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

# Just a t2 micro instance to be free tier eligible
resource "aws_instance" "lb_lab_1" {
  ami           = data.aws_ami.aws_linux_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.merlijn_kp.key_name

  subnet_id              = aws_subnet.pub_subnet_a.id
  vpc_security_group_ids = [aws_security_group.allow_inbound_icmp.id, aws_security_group.allow_inbound_ssh.id, aws_security_group.allow_inbound_web.id, aws_security_group.allow_all_outbound.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_admin_instance_profile.name
  tags = {
    Name = "Load Balanced Instance 1"
  }

  user_data = var.user_data
}

resource "aws_lb_target_group_attachment" "attach_lb1_http_target" {
  target_group_arn = aws_lb_target_group.http_target_group.arn
  target_id        = aws_instance.lb_lab_1.id
  port             = 80
}

resource "aws_instance" "lb_lab_2" {
  ami           = data.aws_ami.aws_linux_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.merlijn_kp.key_name

  subnet_id              = aws_subnet.pub_subnet_b.id
  vpc_security_group_ids = [aws_security_group.allow_inbound_icmp.id, aws_security_group.allow_inbound_ssh.id, aws_security_group.allow_inbound_web.id, aws_security_group.allow_all_outbound.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_s3_admin_instance_profile.name
  tags = {
    Name = "Load Balanced Instance 2"
  }

  user_data = var.user_data
}

resource "aws_lb_target_group_attachment" "attach_lb2_http_target" {
  target_group_arn = aws_lb_target_group.http_target_group.arn
  target_id        = aws_instance.lb_lab_2.id
  port             = 80
}
