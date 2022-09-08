variable "AWS_REGION" {
  default = "us-east-1"
}

variable "AZ" {
  default = "us-east-1a"
}

variable "CIDR" {
  type        = list(any)
  description = "follows as [vpc cidr, subnet 1 cidr, subnet 2 cidr]"
  default     = ["10.0.0.0/16", "10.0.1.0/24", "10.0.11.0/24"]
}

variable "AMI" {
  default = "ami-052efd3df9dad4825"
}

variable "Instance_Type" {
  default = "t2.medium"
}

