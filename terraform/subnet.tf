resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.0.0/24" 
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.1.0/24" 
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.2.0/24" 
  availability_zone = "eu-west-1c"
}
