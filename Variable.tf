variable "project" {
    type        = string
  description = "The project ID to deploy into"
  default = "project-armaggaden-may11"
}

variable "region" {
    type        = string
  description = "The region to deploy into"
  default = "us-central1"
}

variable "zone" {
    type        = string
  description = "The zone to deploy into"
  default = "us-central1-a"
}

variable "credentials" {
    type        = string
  description = "The path to the service account key file"
  default = "project-armaggaden-may11-2cff6047c441.json"
}

variable "vpc_name" {
    type        = string
  description = "The name of the VPC"
  default = "vpc"
}

variable "subnet_name" {
    type        = string
  description = "The name of the subnet"
  default = "us-central1a-subnet"
}

variable "subnet_cidr" {
    type        = string
  description = "The CIDR range for the subnet"
  default = "10.121.2.0/24"
}

variable "autoscaler" {
    type = string
    description = "The name of the autoscaler"
    default = "autoscaler"
}

variable "instance-template" {
    type = string
    description = "romulus-server"
    default = "instance-template"
}

variable "loadbalancer" {
  type = string
  description = "website-forwarding-rule"
  default = "load-balancer82"
}

variable "loadbalancer-ip" {
  type = string
  description = "website-ip-1"
  default = "loadbalancer-ip"
}

variable "proxy-sub01" {
  type = string
  description = "website-proxy"
  default = "proxy-sub01"
}

variable "proxy" {
  type = string
  description = "website-net-proxy"
  default = "proxy"
}

variable "loadbalancer-url" {
  type = string
  description = "loadbalancer"
  default = "loadbalancer"
}

variable "region-instance-group" {
  type = string
  description = "instance-group82"
  default = "region-instance-group"
}

variable "health-check01" {
  type = string
  description = "http-basic-check"
  default = "region-health-check05"
}

variable "health-check02" {
  type = string
  description = "website-hc"
  default = "region-health-check06"
}

variable "firewall-1" {
  type = string
  description = "allow-icmp"
  default = "allow-icmp"
}

variable "firewall-2" {
  type = string
  description = "allow-http"
  default = "http" 
}

variable "firewall-3" {
  type = string
  description = "allow-https"
  default = "https"
}

variable "firewall-4" {
  type = string
  description = "allow-tcp-udp-icmp"
  default = "fwl"
}

variable "firewall-5" {
  type = string
  description = "allow-ssh-tcp"
  default = "fw2"
}

variable "firewall-6" {
  type = string
  description = "website-fw-3"
  default = "fw3"
}

variable "firewall-7" {
  type = string
  description = "website-fw-4-allow-http-https-8000"
  default = "fw4"
}

