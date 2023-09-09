
resource "aws_security_group" "jumpserver_sc" {
  name="${var.env_prefix}-bastion-sc"
  vpc_id=var.vpc_id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name : "${var.env_prefix}-bastion-sc"
  }
}
#Fetch the latest ubuntu AMI
data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical account ID for Ubuntu AMIs
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "bastion-key-pair" {
    key_name ="${var.env_prefix}-bastion-key"
    public_key = file(var.pub_key_path)
}

resource "aws_instance" "bastion" {
    ami = data.aws_ami.ubuntu_20_04.id
    instance_type = var.instance_type
    subnet_id=var.subnet_id
    vpc_security_group_ids = [aws_security_group.jumpserver_sc.id]
    key_name = aws_key_pair.bastion-key-pair.key_name
    associate_public_ip_address = true
    tags = {
        Name : "${var.env_prefix}-bastion"
    }
}