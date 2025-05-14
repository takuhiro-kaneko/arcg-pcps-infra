# Variable Definition 
variable "access_key" {}
variable "secret_key" {}
variable "region" {}

variable "environment" {}
variable "project" {}

# Windows Virtual Machine
variable "windows_instance_type" {
  type = string
}
variable "windows_associate_public_ip_address" {
  type = bool
}
variable "windows_root_volume_size" {
  type = number
}
variable "windows_root_volume_type" {
  type = string
}
variable "windows_data_volume_size" {
  type = number
}
variable "windows_data_volume_type" {
  type = string
}

# Windows Virtual Machine for Private
variable "windows_instance_type_private" {
  type = string
}

# AWS プロバイダの設定
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}
