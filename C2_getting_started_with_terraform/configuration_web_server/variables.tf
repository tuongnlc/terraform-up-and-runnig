variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "firewall_rule" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance"
}