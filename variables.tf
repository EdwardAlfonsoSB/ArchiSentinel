variable "aws_region" {
  description = "La región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "El nombre del entorno (ej. dev, qa, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "El nombre del proyecto, usado para nombrar recursos."
  type        = string
  default     = "archisentinel-app"
}

variable "vpc_cidr_block" {
  description = "El bloque CIDR para la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "El bloque CIDR para la subred pública."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "El bloque CIDR para la subred privada."
  type        = string
  default     = "10.0.2.0/24"
}
