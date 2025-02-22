resource "aws_iam_role" "ecs-instance-role" {
  name                = "${var.service_name}ECSInstanceRole"
  description         = "Allow EC2 instance to use ECS"
  assume_role_policy  = "${data.aws_iam_policy_document.ecs-instance-policy.json}"
  tags                = "${var.tags}"
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = "${aws_iam_role.ecs-instance-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_role_policy_attachment" "ssm-instance-role-attachment" {
  role       = "${aws_iam_role.ecs-instance-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}


resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "${var.service_name}ECSInstanceProfile"
  role = "${aws_iam_role.ecs-instance-role.id}"
}
