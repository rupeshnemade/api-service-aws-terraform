resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${tls_private_key.private_key.public_key_openssh}"
}


resource "aws_security_group" "ecs_ec2_sg" {
  name        = "${var.service_name}-ec2-sg"
  description = "ECS Instance security group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8222
    to_port     = 8222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags   = "${var.tags}"
}


data "aws_ami" "ecs_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  owners = ["amazon"]
}


resource "aws_launch_configuration" "launch" {
  name_prefix   = "${var.service_name}-ecs"
  image_id      = "${data.aws_ami.ecs_ami.id}"
  instance_type = "${var.instance_type}"

  security_groups = [
    "${aws_security_group.ecs_ec2_sg.id}"
  ]

  iam_instance_profile = "${aws_iam_instance_profile.ecs-instance-profile.id}"
  key_name             = "${aws_key_pair.generated_key.key_name}"

  user_data = <<EOF
              #!/bin/bash
              sudo yum -y update
              echo ECS_CLUSTER=${aws_ecs_cluster.hotelService_ecs_cluster.name} >> /etc/ecs/ecs.config
              sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              EOF

  lifecycle {
    create_before_destroy = true
  }

}
