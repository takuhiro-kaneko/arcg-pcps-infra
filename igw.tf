# Definition of internet gateway  
resource "aws_internet_gateway" "arcg-pcps-igw" {
  vpc_id = aws_vpc.arcg-pcps-vpc.id                # Internet Gatewayを配置するVPCを指定

  tags = {
    Name = "ArcGIS PCPS Internet Gateway"
  }
}