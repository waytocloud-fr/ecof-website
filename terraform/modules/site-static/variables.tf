variable "domain_name" {
  description = "Nom de domaine du site"
  type        = string
}

variable "environment" {
  description = "Environnement (stage, prod)"
  type        = string
  default     = "stage"
}