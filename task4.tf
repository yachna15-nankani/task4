provider "aws" {
 region = "ap-south-1"
 profile = "task4"
}
resource "aws_instance" "myos1" {
 ami = "ami-000cbce3e1b899ebd"
 instance_type = "t2.micro"
 associate_public_ip_address = true
 key_name = "my1key"
 vpc_security_group_ids = [aws_security_group.my_webserver.id]
 subnet_id = aws_subnet.Public_subnet.id 
 tags = {
  Name = "MyWord-Yachna"
 }
}
resource "aws_instance" "myos2" {
 ami = "ami-0019ac6129392a0f2"
 instance_type = "t2.micro"
 key_name = "my1key"
 vpc_security_group_ids = [aws_security_group.my_database.id]
 subnet_id = aws_subnet.Private_subnet.id 
 tags = {
  Name = "MySql-Yachna"
 }
}

resource "aws_security_group" "my_webserver" {
 name = "my_wordpress"
 vpc_id = "${aws_vpc.main.id}"
 ingress {
  description = "SSH"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
  ingress {
  description = "HTTP"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 }
  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
  Name = "mywpsecurity"
 }
}

resource "aws_security_group" "my_database" {
 name = "my_security"
 vpc_id = "${aws_vpc.main.id}"
 ingress {
  description = "MYSQL"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_groups=[aws_security_group.my_webserver.id]
  }
  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 tags = {
  Name = "mysqlsecurity"
 }
}
resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "mytask4vpc"
  }
}
resource "aws_route_table" "myroute_table" {
 vpc_id = "${aws_vpc.main.id}"
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.mygate.id}"
 } 
 tags = {
  Name = "myroutetable"
 }
}
resource "aws_route_table_association" "a1" {
 subnet_id = aws_subnet.Public_subnet.id
 route_table_id = aws_route_table.myroute_table.id
}
resource "aws_eip" "mynat" {
 vpc=true
}
resource "aws_nat_gateway" "mynatgw" {
 allocation_id="${aws_eip.mynat.id}"
 subnet_id="${aws_subnet.Public_subnet.id}"
 depends_on=[aws_internet_gateway.mygate]
 tags={
  Name="mygateway"
 }
}
resource "aws_route_table" "myroute_table1" {
 vpc_id = "${aws_vpc.main.id}"
 route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.mynatgw.id}"
 } 
 tags = {
  Name = "myroutetable1"
 }
}
resource "aws_route_table_association" "nat1" {
 subnet_id = aws_subnet.Private_subnet.id
 route_table_id = aws_route_table.myroute_table1.id
}
resource "aws_subnet" "Public_subnet" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block="192.168.0.0/24"
 availability_zone="ap-south-1a"
 tags={
  Name="public_subnet"
 }
}
resource "aws_subnet" "Private_subnet" {
 vpc_id = "${aws_vpc.main.id}"
 cidr_block="192.168.1.0/24"
 availability_zone="ap-south-1b"
 tags={
  Name="private_subnet"
 }
}
resource "aws_internet_gateway" "mygate" {
 vpc_id = "${aws_vpc.main.id}"
 tags={
  Name="internet-gateway"
 }
}