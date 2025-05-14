# Definition of private route table 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.arcg-pcps-vpc.id                                     # Route Tableを配置するVPCを指定

  tags = {
    Name = "ArcGIS PCPS Private Route Table"
  }
}

resource "aws_route" "private" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.arcg-pcps-ngw.id         # NAT Gateway への経路情報を追加
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id                  # Private Subnetと紐付け
  route_table_id = aws_route_table.private.id
}