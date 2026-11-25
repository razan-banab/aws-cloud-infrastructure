resource "aws_acm_certificate" "cloudforge" {
  domain_name       = "www.cloudforge.freeddns.org"
  validation_method = "DNS"

  tags = {
    Name    = "cloudforge-certificate"
    Project = "cloudforge"

  }

  lifecycle {
    create_before_destroy = true
  }
}

output "acm_validation_records" {
  description = "ACM DNS validation records"

  value = {
    for dvo in aws_acm_certificate.cloudforge.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}