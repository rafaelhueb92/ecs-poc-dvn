resource "aws_subnet" "private_1a" {
  vpc_id                   = aws_vpc.this.id
  cidr_block               = "10.0.0.128/26"
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "dvn-private-subnet-1a"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id                   = aws_vpc.this.id
  cidr_block               = "10.0.0.192/26"
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "dvn-private-subnet-1b"
  }
}