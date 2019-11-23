output "distribution_id" {
  value = "${aws_cloudfront_distribution.s3_distribution.id}"
  description = "Id of the Cloudfront Distribution"
}

output "domain_name" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
  description = "Domain name of the Cloudfront Distribution"
}