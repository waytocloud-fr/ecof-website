terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "ecof-website"
}

variable "environment" {
  description = "Environnement (stage, prod)"
  type        = string
  default     = "stage"
}

variable "enable_custom_domain" {
  description = "Activer le domaine personnalisé avec Route53 et ACM"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Nom de domaine du site (optionnel)"
  type        = string
  default     = ""
}