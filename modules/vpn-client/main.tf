variable "name" {}
variable "subnet_id" {}
variable "security_groups" {}
variable "key_name" {}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "vpn_client" {
  ami           = "${data.aws_ami.ubuntu.id}"
  subnet_id     = "${var.subnet_id}"
  vpc_security_group_ids = var.security_groups
  instance_type = "t2.micro"
  key_name = var.key_name

  tags = {
    Name = "${var.name}"
  }
}

output "instance_id" {
    value = aws_instance.vpn_client.id
}
