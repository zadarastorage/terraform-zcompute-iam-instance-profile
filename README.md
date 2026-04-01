# Zadara zCompute IAM Instance Profile Terraform Module

A Terraform module for creating IAM instance profiles, roles, and policies for Zadara zCompute instances. This module simplifies the process of setting up IAM resources needed for EC2 instances to access other AWS-compatible services.

## Features

- **Instance Profile Creation**: Complete instance profile lifecycle management
- **IAM Role Management**: Create new roles or use existing ones
- **IAM Policy Management**: Create new policies or attach existing ones
- **Assume Role Policy**: Default EC2 assume role policy with customization support
- **Flexible Naming**: Configurable paths and names for all IAM resources
- **Policy Content Hashing**: Automatic policy versioning via content hash

## Usage

### Basic Instance Profile with Custom Policy

This example creates an instance profile with a custom policy allowing S3 access:

```hcl
module "iam_instance_profile" {
  source = "zadarastorage/iam-instance-profile/zcompute"
  # It's recommended to pin to a specific version
  # version = "1.0.0"

  name        = "my-app-instance-profile"
  policy_name = "my-app-policy"
  role_name   = "my-app-role"

  policy_contents = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  }
}
```

### Using an Existing Role

If you already have an IAM role and want to create an instance profile for it:

```hcl
module "iam_instance_profile" {
  source = "zadarastorage/iam-instance-profile/zcompute"

  name              = "my-instance-profile"
  use_existing_role = true
  role_name         = "existing-role-name"

  policy_contents = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      }
    ]
  }
}
```

### Using an Existing Policy

To attach an existing policy to a new role and instance profile:

```hcl
module "iam_instance_profile" {
  source = "zadarastorage/iam-instance-profile/zcompute"

  name                = "my-instance-profile"
  role_name           = "my-role"
  use_existing_policy = true
  policy_arn          = "arn:aws:iam::123456789012:policy/existing-policy"

  # policy_contents is still required but not used when use_existing_policy = true
  policy_contents = {}
}
```

## Provider Configuration

To use this module with Zadara zCompute, you must configure the AWS provider with custom endpoints:

```hcl
variable "zcompute_endpoint_url" {
  type        = string
  description = "IP/DNS of zCompute Region API Endpoint. ex: https://compute-us-west-101.zadara.com"
}

variable "zcompute_access_key" {
  type        = string
  description = "Amazon style zCompute access key"
}

variable "zcompute_secret_key" {
  type        = string
  sensitive   = true
  description = "Amazon style zCompute secret key"
}

provider "aws" {
  endpoints {
    ec2         = "${var.zcompute_endpoint_url}/api/v2/aws/ec2"
    autoscaling = "${var.zcompute_endpoint_url}/api/v2/aws/autoscaling"
    elb         = "${var.zcompute_endpoint_url}/api/v2/aws/elbv2"
    s3          = "${var.zcompute_endpoint_url}:1061/"
    rds         = "${var.zcompute_endpoint_url}/api/v2/aws/rds"
    iam         = "${var.zcompute_endpoint_url}/api/v2/aws/iam"
    route53     = "${var.zcompute_endpoint_url}/api/v2/aws/route53"
    sts         = "${var.zcompute_endpoint_url}/api/v2/aws/sts"
  }

  region   = "us-east-1"
  insecure = "true"

  access_key = var.zcompute_access_key
  secret_key = var.zcompute_secret_key
}
```

## zCompute Compatibility Notes

This module is designed specifically for Zadara zCompute IAM compatibility:

- **No Tag Support**: zCompute IAM does not support resource tagging (commented out in module)
- **Policy Hashing**: Policies include content hash in name to handle updates correctly
- **Instance Profile ID**: The output returns `unique_id` rather than name due to zCompute 22.09.x launch configuration requirements

## Requirements and Dependencies

See the terraform-docs generated sections below for detailed requirements, providers, resources, inputs, and outputs.

<!-- BEGIN_TF_DOCS -->
## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.33.0, <= 4.34.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.33.0, <= 4.34.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Resources

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [time_sleep.consistency_delay](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_delay_seconds"></a> [create\_delay\_seconds](#input\_create\_delay\_seconds) | Seconds to wait before creating IAM resources. Use when a prior<br/>destroy did not include a destroy delay — the IAM API may reject<br/>create calls with "already used" for several minutes after delete. | `number` | `0` | no |
| <a name="input_destroy_delay_seconds"></a> [destroy\_delay\_seconds](#input\_destroy\_delay\_seconds) | Seconds to wait after destroying IAM resources before terraform<br/>exits. Gives the backend time to fully purge deleted resources<br/>so the names are immediately reusable on the next apply.<br/>Default: 360 (6 minutes), based on measured eventual consistency<br/>window of 3-6 minutes on zCompute. | `number` | `360` | no |
| <a name="input_instance_profile_path"></a> [instance\_profile\_path](#input\_instance\_profile\_path) | IAM Instance Profile Path | `string` | `"/"` | no |
| <a name="input_name"></a> [name](#input\_name) | Instance profile name | `string` | n/a | yes |
| <a name="input_policy_arn"></a> [policy\_arn](#input\_policy\_arn) | ARN to an existing policy to use | `string` | `null` | no |
| <a name="input_policy_contents"></a> [policy\_contents](#input\_policy\_contents) | n/a | `any` | n/a | yes |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | n/a | `string` | `null` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | n/a | `string` | `null` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | IAM Policy Path | `string` | `"/"` | no |
| <a name="input_role_contents"></a> [role\_contents](#input\_role\_contents) | n/a | `any` | `null` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | n/a | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | n/a | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | IAM Role Path | `string` | `"/"` | no |
| <a name="input_use_existing_policy"></a> [use\_existing\_policy](#input\_use\_existing\_policy) | Controls if an IAM Policy should be created or reused | `bool` | `false` | no |
| <a name="input_use_existing_role"></a> [use\_existing\_role](#input\_use\_existing\_role) | Controls if an IAM role should be created or reused | `bool` | `false` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_profile_name"></a> [instance\_profile\_name](#output\_instance\_profile\_name) | In 22.09.x the launch configuration expecting the unique id and not the instance profile name. |
<!-- END_TF_DOCS -->

## Contributing

Contributions are welcome! Please open an issue or pull request for any bugs, feature requests, or improvements.

## License

Apache 2 Licensed. See LICENSE for full details.
