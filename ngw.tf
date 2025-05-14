# Definition of nat gateway 
resource "aws_eip" "arcg-pcps-eip" {
  domain = "vpc"

  tags = {
    Name = "ArcGIS PCPS Elastic IP"
  }
}

resource "aws_nat_gateway" "arcg-pcps-ngw" {
  subnet_id     = aws_subnet.public.id   # NAT Gatewayを配置するSubnetを指定
  allocation_id = aws_eip.arcg-pcps-eip.id         # 紐付けるElasti IP

  tags = {
    Name = "ArcGIS PCPS NAT Gateway"
  }
}