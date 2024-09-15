variable "env" {
  default = "infra"
}

variable "region" {
  default = "eu-north-1"
}

variable "zone_1" {
  default = "eu-north-1a"
}

variable "zone_2" {
  default = "eu-north-1b"
}

variable "eks_name" {
  default = "test"
}

variable "eks_version" {
  default = "1.30"
}

variable "capacity_type" {
  default = "ON_DEMAND"
}

variable "instance_type" {
  default     = "t3.medium"
  description = "EKS node instance type"
}

variable "instance_count" {
  default     = 3
  description = "EKS node count"
}

variable "dez_instance_count" {
  default = 3
}

variable "max_instance_count" {
  default = 5
}

variable "min_instance_count" {
  default = 0
}
