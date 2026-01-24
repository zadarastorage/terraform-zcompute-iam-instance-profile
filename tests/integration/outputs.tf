output "instance_profile_unique_id" {
  description = "The unique ID of the instance profile (used by zCompute launch configurations)"
  value       = module.iam_instance_profile.instance_profile_name
}

output "role_name" {
  description = "The name of the IAM role"
  value       = "test-role-${var.name_suffix}"
}

output "policy_name_prefix" {
  description = "The prefix of the policy name (full name includes MD5 hash of contents)"
  value       = "test-policy-${var.name_suffix}"
}
