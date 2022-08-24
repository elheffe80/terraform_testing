provider "aws" {
  region = "us-east-2"
}

variable "port_number" {
  description	= "Port number used for serving the web page"
  type 		= number
  default	= 8080
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  
  ingress {
    from_port 	= var.port_number
    to_port  	= var.port_number
    protocol	= "tcp"
    cidr_blocks	= ["0.0.0.0/0"]
  }
}

resource "aws_instance" "kittendancer" {
  ami			 = "ami-0fb653ca2d3203ac1"
  instance_type 	 = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = 	<<-EOF
		#!/bin/bash
		echo "Hello, World. You smell." > index.html
		nohup busybox httpd -f -p ${var.port_number} &
		EOF

  user_data_replace_on_change = true
  
  tags = {
    Name = "terraform-example-kittania"
  }
}

output "public_ip" {
  value               = aws_instance.kittendancer.public_ip
  description         = "The public IP address of the web server" 
}
