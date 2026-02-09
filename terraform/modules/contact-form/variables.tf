variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "ecof"
}

variable "environment" {
  description = "Environnement (dev, prod)"
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Tags à appliquer aux ressources"
  type        = map(string)
  default     = {}
}
