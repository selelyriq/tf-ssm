variable "target_key" {
  description = "The tag key to use for targeting instances (e.g., 'AutoScalingGroup')"
  type        = string
  default     = "AutoScalingGroup"
}

variable "target_values" {
  description = "List of tag values to target for the specified tag key"
  type        = list(string)
}

variable "efs_id" {
  description = "The ID of the EFS filesystem"
  type        = string
}

variable "scripts" {
  description = "Map of script names to script file paths. These should be provided by the root module."
  type        = map(string)
  default     = {}
}