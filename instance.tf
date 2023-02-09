resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Public security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "public" {
  ami                         = "ami-0aa7d40eeae50c9a9"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "devops"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id

  tags = {
    Name = "${var.env_code}-public"
  }
}