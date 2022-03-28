variable "server_port" {
    description = "The from and to port for our webserver"
    type = number
    default = 8080
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance"
}