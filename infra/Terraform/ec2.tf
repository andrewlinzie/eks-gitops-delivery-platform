# Get latest Ubuntu 22.04 AMI dynamically
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance for Jenkins Master
resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_master.id]
  key_name               = "my-desktop-keypair" # replace with your keypair name
  iam_instance_profile   = aws_iam_instance_profile.jenkins_master.name

  associate_public_ip_address = true # enables SSH from outside

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "jenkins-master"
  }
}