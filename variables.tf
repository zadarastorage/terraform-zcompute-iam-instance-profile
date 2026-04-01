variable "name" {
  description = "Instance profile name"
  type        = string
}

variable "instance_profile_path" {
  description = "IAM Instance Profile Path"
  type        = string
  default     = "/"
}
variable "role_path" {
  description = "IAM Role Path"
  type        = string
  default     = "/"
}
variable "policy_path" {
  description = "IAM Policy Path"
  type        = string
  default     = "/"
}

variable "use_existing_role" {
  description = "Controls if an IAM role should be created or reused"
  type        = bool
  default     = false
}
variable "role_name" {
  description = ""
  type        = string
  default     = null
}
variable "role_description" {
  description = ""
  type        = string
  default     = null
  nullable    = true
}
variable "role_contents" {
  description = ""
  type        = any
  default     = null
  nullable    = true
}

variable "use_existing_policy" {
  description = "Controls if an IAM Policy should be created or reused"
  type        = bool
  default     = false
}
variable "policy_name" {
  description = ""
  type        = string
  default     = null
}
variable "policy_description" {
  description = ""
  type        = string
  default     = null
  nullable    = true
}
variable "policy_contents" {
  description = ""
  type        = any
}
variable "policy_arn" {
  description = "ARN to an existing policy to use"
  type        = string
  default     = null
  nullable    = true
}

variable "create_delay_seconds" {
  description = <<-EOT
    Seconds to wait before creating IAM resources. Use when a prior
    destroy did not include a destroy delay — the IAM API may reject
    create calls with "already used" for several minutes after delete.
  EOT
  type        = number
  default     = 0
}

variable "destroy_delay_seconds" {
  description = <<-EOT
    Seconds to wait after destroying IAM resources before terraform
    exits. Gives the backend time to fully purge deleted resources
    so the names are immediately reusable on the next apply.
    Default: 360 (6 minutes), based on measured eventual consistency
    window of 3-6 minutes on zCompute.
  EOT
  type        = number
  default     = 360
}

#variable "tags" {
#  description = "A map of tags to add to all resources"
#  type        = map(string)
#  default     = {}
#}
