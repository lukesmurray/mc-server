# Defines all the aws resources needed to run a minecraft server.


# make some assertions about terraform
terraform {
  required_version = "> 0.11"
}

# set the provider to amazon web services
# region is set in variables
# profile is set by aws configure
provider "aws" {
  profile = "default"
  region  = var.region
}

# resource group controls server ports
resource "aws_security_group" "mc_auto_security_group" {
  name        = "mc_auto_security_group"
  description = "security group for automatic minecraft server"

  # allow ssh access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ssh access"
  }

  # minecraft tcp access
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "minecraft tcp access"
  }

  # minecraft udp access
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "mninecraft udp access"
  }

  # minecraft udp access
  ingress {
    from_port   = 19132
    to_port     = 19133
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "minecraft udp access"
  }

  # allow anyone to get traffic from the network
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow anyone to get traffic from the network"
  }

  # set the tags
  tags = {
    project = var.project_tag
  }
}

# key for ssh access
resource "aws_key_pair" "mc_auto_key_pair" {
  key_name   = var.aws_key_name
  public_key = var.aws_public_key
}

# get the most recent amazon-linux-2 ami
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["amazon"]
}

# create the instance
resource "aws_instance" "mc_auto_instance" {
  ami             = "${data.aws_ami.amazon-linux-2.id}"
  instance_type   = var.instance_type
  key_name        = "${aws_key_pair.mc_auto_key_pair.key_name}"
  security_groups = ["${aws_security_group.mc_auto_security_group.name}"]

  root_block_device {
    volume_type = "gp2"
    volume_size = 15 # storage size of the volume in gb
  }

  # t3 are unlimited by default, t2 are standard
  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    project = var.project_tag
  }

  # specify the ssh connection parameters
  connection {
    user = "ec2-user"
    host = "${aws_instance.mc_auto_instance.public_ip}"
  }

  # create necessary directories 
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /app",
      "sudo setfacl -m u:ec2-user:rwx /app"
    ]
  }

  # copy script files to the server
  provisioner "file" {
    source      = "./mc-server-scripts/"
    destination = "/app"
  }

  # execute the setup script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /app/autoshutdown.sh",
      "chmod +x /app/setup.sh",
      "chmod +x /app/startup.sh",
      "/app/setup.sh"
    ]
  }

  # execute the startup script
  provisioner "remote-exec" {
    inline = [
      "/app/startup.sh"
    ]
  }
}
