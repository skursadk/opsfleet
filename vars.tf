### MANDATORY PARAMS ###
variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  description = "Private subnets CIDR list"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets CIDR list"
  type        = list(string)
}

### OPTIONAL PARAMS ###
variable "aws_auth_users" {
  description = "AWS Users to K8s User Map"
  type        = list(any)
  default     = []
}

variable "aws_auth_roles" {
  description = "AWS Roles to K8s User Map"
  type        = list(any)
  default     = []
}
