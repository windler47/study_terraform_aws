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

resource "aws_instance" "sobes_windler47_instance" {
  ami           = "${data.aws_ami.ubuntu.id}"
  subnet_id     = var.subnet_id
  instance_type = "t2.micro"
  vpc_security_group_ids = var.security_groups
  key_name = var.key_name
  tags = {
    Name = "sobes_windler47_instance"
  }
}

output "instance_id" {
    value = aws_instance.sobes_windler47_instance.id
}
