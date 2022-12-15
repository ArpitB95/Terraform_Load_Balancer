

# Defining Public Key
variable "access_key" {
  default = "your access key"
}
# Defining Private Key
variable "secret_key" {
  default = "your secret key"
}

# Defining CIDR Block for VPC
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
# Defining CIDR Block for first Subnet
variable "subnet1_cidr" {
  default = "10.0.1.0/24"
}
# Defining CIDR Block for 2d Subnet
variable "subnet2_cidr" {
  default = "10.0.2.0/24"
}

variable "ami" {
  default = "ami-05e786af422f8082a"
}


variable "instance_type" {
  default = "t2.micro"
}
