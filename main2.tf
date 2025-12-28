provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------
# 1. VPC Endpoint
# JSON ID: VPC_Endpoint
# ---------------------------------------------------------
resource "aws_vpc_endpoint" "VPC_Endpoint" {
  vpc_id       = "vpc-mock-id-12345"
  service_name = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
}

# ---------------------------------------------------------
# 2. Lambda: Listar
# JSON ID: Lambda_Listar
# ---------------------------------------------------------
resource "aws_lambda_function" "Lambda_Listar" {
  function_name = "ListarItemsFunction"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.Roles.arn
}

# ---------------------------------------------------------
# 3. Lambda: Crear
# JSON ID: Lambda_Crear
# ---------------------------------------------------------
resource "aws_lambda_function" "Lambda_Crear" {
  function_name = "CrearItemsFunction"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.Roles.arn
}

# ---------------------------------------------------------
# 3.1. Lambda: Actualizar
# JSON ID: Lambda_Actualizar
# ---------------------------------------------------------
resource "aws_lambda_function" "Lambda_Actualizar" {
  function_name = "UpdateItemsFunction"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.Roles.arn
}

# ---------------------------------------------------------
# 4. VPC Link (Conectividad API Gateway)
# JSON ID: VPC_Link
# ---------------------------------------------------------
resource "aws_api_gateway_vpc_link" "VPC_Link" {
  name        = "vpc-link-interno"
  target_arns = [] # Se requeriría un NLB real aquí
}

# ---------------------------------------------------------
# 5. API Gateway
# JSON ID: Api_Gateway
# ---------------------------------------------------------
resource "aws_api_gateway_rest_api" "Api_Gateway" {
  name        = "MiApiPrincipal"
  description = "Gateway principal de la arquitectura"
}

# ---------------------------------------------------------
# 6. IAM (Servicio General / Alias)
# JSON ID: IAM
# ---------------------------------------------------------
resource "aws_iam_account_alias" "IAM" {
  account_alias = "alias-cuenta-arquitectura"
}

# ---------------------------------------------------------
# 7. Roles IAM
# JSON ID: Roles
# ---------------------------------------------------------
resource "aws_iam_role" "Roles" {
  name = "RolEjecucionLambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# ---------------------------------------------------------
# 8. Permisos IAM (Políticas)
# JSON ID: Permisos
# ---------------------------------------------------------
resource "aws_iam_policy" "Permisos" {
  name        = "PoliticaAccesoDynamoDB"
  description = "Permisos de lectura y escritura"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:*"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ---------------------------------------------------------
# 9. CloudWatch (Dashboard)
# JSON ID: Cloudwatch
# ---------------------------------------------------------
resource "aws_cloudwatch_dashboard" "Cloudwatch" {
  dashboard_name = "DashboardOperativo"
  dashboard_body = "{\"widgets\":[]}"
}

# ---------------------------------------------------------
# 10. WAF (Web Application Firewall)
# JSON ID: WAF
# ---------------------------------------------------------
resource "aws_wafv2_web_acl" "WAF" {
  name        = "WAF-FrontEnd"
  description = "Protección para CloudFront"
  scope       = "CLOUDFRONT"
  
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAFMetrics"
    sampled_requests_enabled   = true
  }
}

# ---------------------------------------------------------
# 11. Shield (Protección DDoS)
# JSON ID: Shield
# ---------------------------------------------------------
resource "aws_shield_protection" "Shield" {
  name         = "ProteccionDDoS-CDN"
  resource_arn = aws_cloudfront_distribution.Cloudront.arn
}

# ---------------------------------------------------------
# 12. Cognito (User Pool)
# JSON ID: Cognito
# ---------------------------------------------------------
resource "aws_cognito_user_pool" "Cognito" {
  name = "UserPool-UsuariosApp"
}

# ---------------------------------------------------------
# 13. CloudFront
# JSON ID: Cloudront (Nota: Mantenemos el nombre SIN la 'f' para coincidir con el JSON)
# ---------------------------------------------------------
resource "aws_cloudfront_distribution" "Cloudront" {
  origin {
    domain_name = aws_s3_bucket.S3_SPA_Codigo_estatico.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# ---------------------------------------------------------
# 14. S3 Bucket (SPA)
# JSON ID: S3_SPA_Codigo_estatico
# ---------------------------------------------------------
resource "aws_s3_bucket" "S3_SPA_Codigo_estatico" {
  bucket = "mi-bucket-spa-prod-xy123"
}
