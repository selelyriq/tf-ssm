variable "instance_id" {
  description = "The ID of the instance to run the command on"
  type        = string
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