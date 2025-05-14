# Definition of public route table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.arcg-pcps-vpc.id                                  # Route Tableを配置するVPCを指定

  tags = {
    Name = "ArcGIS PCPS Public Route Table"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.arcg-pcps-igw.id     # Internet Gateway への経路情報を追加
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id                     # Public Subnetと紐付け
  route_table_id = aws_route_table.public.id
}