variable "aws_region" {
  description = " The Regions we will be deploying our resources across"
}
variable "vpc_cidr" {
  description = "Our VPCS CIDR range"
}

variable "public_subnet_cidrs" {
  description = "Public CIDR Range"
}

variable "private_subnet_cidrs" {
  description = "Private CIDR Range"
}

variable "azs" {
  description = "List of AZs we will deploy to"
}

variable "tags" {
  description = "Our Default tag"

}