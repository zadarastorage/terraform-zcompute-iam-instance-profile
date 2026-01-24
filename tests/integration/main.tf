# Integration Test Fixture for IAM Instance Profile Module
#
# Creates a complete IAM instance profile with role and policy
# using test-* naming convention for cleanup identification.

module "iam_instance_profile" {
  source = "../.."

  name                  = "test-${var.name_suffix}"
  instance_profile_path = "/"

  use_existing_role   = false
  use_existing_policy = false

  role_name = "test-role-${var.name_suffix}"
  role_path = "/"

  policy_name = "test-policy-${var.name_suffix}"
  policy_path = "/"
  policy_contents = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = ["*"]
      }
    ]
  }
}
