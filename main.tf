provider "aws" {
  region = var.aws_region
}

# --- Red ---
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block
  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# --- Almacenamiento Frontend (S3) ---
resource "aws_s3_bucket" "web_app_hosting" {
  bucket = "${var.project_name}-spa-hosting-${var.environment}"
  # TODO: Configurar como website hosting si es necesario y añadir políticas de bucket.
  tags = {
    Name = "WebAppHostingS3"
  }
}

# --- CDN (CloudFront) ---
resource "aws_cloudfront_distribution" "web_app_cdn" {
  origin {
    domain_name = aws_s3_bucket.web_app_hosting.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.web_app_hosting.id}"
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # TODO: Configurar OAI, WAF, y comportamientos de caché específicos.
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "WebAppCDN"
  }
}

# --- Seguridad ---
resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.project_name}-user-pool-${var.environment}"
  # TODO: Configurar políticas de contraseña, MFA, y otros detalles.
  tags = {
    Name = "UserPool"
  }
}

resource "aws_wafv2_web_acl" "web_app_firewall" {
  name  = "${var.project_name}-waf-${var.environment}"
  scope = "CLOUDFRONT"
  # TODO: Definir las reglas específicas del WAF (ej. AWS Managed Rules).
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WebAppFirewall"
    sampled_requests_enabled   = true
  }
  tags = {
    Name = "WebAppFirewall"
  }
}

# --- API y Cómputo (API Gateway & Lambda) ---
resource "aws_api_gateway_rest_api" "main_api_gateway" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "Punto de entrada para las APIs del proyecto."
  tags = {
    Name = "MainAPIGateway"
  }
}

resource "aws_lambda_function" "list_items_function" {
  function_name = "ListItemsFunction"
  handler       = "index.handler"
  runtime       = "nodejs20.x" # TODO: Confirmar runtime y handler
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = "lambda_code/list_items.zip" # TODO: Subir el código fuente de la Lambda
  tags = {
    Name = "ListItemsFunction"
  }
}

resource "aws_lambda_function" "create_items_function" {
  function_name = "CreateItemsFunction"
  handler       = "index.handler"
  runtime       = "nodejs20.x" # TODO: Confirmar runtime y handler
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = "lambda_code/create_items.zip" # TODO: Subir el código fuente de la Lambda
  tags = {
    Name = "CreateItemsFunction"
  }
}

# --- IAM ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  # TODO: Adjuntar políticas con los permisos necesarios para las Lambdas.
  tags = {
    Name = "AppIAM"
  }
}
