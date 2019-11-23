variable "dns_name" {
  type = string
  description = "The DNS name of the site"
}

variable "certificate_arn" {
    type = string
    description = "The ARN of the ACM Certificate for the dns_name"
}

variable "route53_zone" {
    type = string
    description = "The Zone ID of the Route53 zone this route should belong to"
}