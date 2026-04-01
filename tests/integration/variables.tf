variable "name_suffix" {
  description = "Suffix for unique resource names (typically github.run_id)"
  type        = string
}

variable "create_delay_seconds" {
  description = "Override module's create_delay_seconds. Omit to use module default."
  type        = number
  default     = null
}

variable "destroy_delay_seconds" {
  description = "Override module's destroy_delay_seconds. Omit to use module default."
  type        = number
  default     = null
}
