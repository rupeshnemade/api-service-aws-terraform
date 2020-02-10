data "aws_iam_policy_document" "ecs_role_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "${var.service_name}EcsRole"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_role_document.json}"
  tags               = "${var.tags}"
}