resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"  
}
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.my_vpc.id
}