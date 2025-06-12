# variable "instance_id" {
#   description = "The ID of the instance to run the command on"
#   type        = string
# }

variable "scripts" {
  description = "The scripts to run on the instance"
  type        = map(string)
  default = {
    hello_world = "scripts/hello_world.sh"
    ping_google = "scripts/ping_google.sh"
  }
}