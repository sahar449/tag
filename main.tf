provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "test" {
  ami = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  tags = {
    owner = var.name
  }
}

variable "name" {
  type    = string
  default = "default_value"
}