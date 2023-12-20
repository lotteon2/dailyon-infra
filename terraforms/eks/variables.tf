variable "external_dns_arn" {
  description = "The external dns arn about route53 for the alb"
  type        = string
  sensitive   = true

  validation {
    condition     = substr(var.external_dns_arn, 0, 15) == "arn:aws:route53"
    error_message = "external dns arn is not valid."
  }
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