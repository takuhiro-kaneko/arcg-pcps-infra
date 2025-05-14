# Definition of subnet 

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.arcg-pcps-vpc.id       # Subnetを配置するVPCを指定
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"   # Subnetを配置するAvailability Zoneを指定

  tags = {
    Name = "ArcGIS PCPS Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.arcg-pcps-vpc.id       # Subnetを配置するVPCを指定
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"   # Subnetを配置するAvailability Zoneを指定

  tags = {
    Name = "ArcGIS PCPS Private Subnet"
  }
}
