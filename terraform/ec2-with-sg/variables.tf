variable "ec2_os" {
  description = "OS of the ec2 [RHEL-10/Ubuntu-24]"
  type        = string
  validation {
    condition     = length(var.ec2_os) > 0 && contains(keys(local.ami_map), lower(var.ec2_os))
    error_message = "Invalid OS type"
  }
}

variable "ec2_name" {
  description = "Name of the ec2"
  type        = string
  default     = "test-ec2_tf"
}