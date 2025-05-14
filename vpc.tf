# Definition of vpc
resource "aws_vpc" "arcg-pcps-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ArcGIS PCPS VPC"
  }
}
