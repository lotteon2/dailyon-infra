variable "external_dns" {
  description = "The external dns for admin frontend"
  type        = string
  sensitive   = true
}

variable "route53_zone_id" {
  description = "The external route53 zone id for frontend"
  type        = string
  sensitive   = true
}

variable "external_cert_arn" {
  description = "The external cert arn about domain ssl for the alb"
  type        = string
  sensitive   = true

  validation {
    condition     = substr(var.external_cert_arn, 0, 11) == "arn:aws:acm"
    error_message = "external cert arn is not valid."
  }
}