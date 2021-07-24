data "aws_iam_policy" "S3admin" {
  name = "AmazonS3FullAccess"
}

resource "aws_iam_role" "ec2_s3_admin" {
  name = "ec2-S3-admin"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.S3admin.arn]


  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "ec2_s3_admin_instance_profile" {
  name = "ec2_s3_admin_instance_profile"
  role = aws_iam_role.ec2_s3_admin.name
}
