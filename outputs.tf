output "cloudfront_distribution_domain_name" {
  description = "El nombre de dominio de la distribución de CloudFront."
  value       = aws_cloudfront_distribution.web_app_cdn.domain_name
}

output "s3_bucket_name" {
  description = "El nombre del bucket S3 que aloja el SPA."
  value       = aws_s3_bucket.web_app_hosting.bucket
}

output "api_gateway_invoke_url" {
  description = "La URL base para invocar la API Gateway."
  value       = aws_api_gateway_rest_api.main_api_gateway.execution_arn
}

output "cognito_user_pool_id" {
  description = "El ID del User Pool de Cognito."
  value       = aws_cognito_user_pool.user_pool.id
}
