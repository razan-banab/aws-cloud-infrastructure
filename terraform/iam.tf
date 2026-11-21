resource "aws_iam_role" "session_manager_role" {
  name = "session-manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy" "session_manager_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "parameter_store_policy" {
  name = "parameter_store_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = aws_ssm_parameter.db_password.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "session_manager_attachment" {
  role       = aws_iam_role.session_manager_role.name
  policy_arn = data.aws_iam_policy.session_manager_policy.arn
}
resource "aws_iam_role_policy_attachment" "parameter_store_policy_attachement" {
  role       = aws_iam_role.session_manager_role.name
  policy_arn = aws_iam_policy.parameter_store_policy.arn
}


resource "aws_iam_instance_profile" "profile" {
  name = "cloud-project-ec2-session-profile"
  role = aws_iam_role.session_manager_role.name
}
