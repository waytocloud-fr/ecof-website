#!/bin/bash

# Script de déploiement sécurisé pour l'infrastructure ECOF
# Ce script suit les meilleures pratiques de sécurité Terraform

set -euo pipefail

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Terraform
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform n'est pas installé"
        exit 1
    fi
    
    # Vérifier AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI n'est pas installé"
        exit 1
    fi
    
    # Vérifier les credentials AWS
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "Credentials AWS non configurés ou invalides"
        log_info "Configurez vos credentials avec:"
        log_info "  - aws configure"
        log_info "  - export AWS_ACCESS_KEY_ID=..."
        log_info "  - export AWS_SECRET_ACCESS_KEY=..."
        exit 1
    fi
    
    log_success "Prérequis validés"
}

# Déploiement du bootstrap
deploy_bootstrap() {
    log_info "Déploiement de l'infrastructure de bootstrap..."
    
    cd terraform/bootstrap
    
    # Initialisation
    terraform init
    
    # Validation
    terraform validate
    
    # Plan
    log_info "Génération du plan Terraform..."
    terraform plan -out=bootstrap.tfplan
    
    # Demander confirmation
    echo
    log_warning "Vous êtes sur le point de créer l'infrastructure de bootstrap."
    log_warning "Cela inclut les buckets S3 et la table DynamoDB pour le state management."
    read -p "Continuer ? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Déploiement annulé"
        exit 0
    fi
    
    # Apply
    terraform apply bootstrap.tfplan
    
    # Nettoyer le plan
    rm -f bootstrap.tfplan
    
    log_success "Bootstrap déployé avec succès"
    
    # Afficher les outputs
    log_info "Informations du backend créé:"
    terraform output
    
    cd ../..
}

# Déploiement de l'environnement
deploy_environment() {
    local env=$1
    
    log_info "Déploiement de l'environnement: $env"
    
    cd "terraform/env/$env"
    
    # Initialisation avec le backend sécurisé
    terraform init
    
    # Validation
    terraform validate
    
    # Plan
    log_info "Génération du plan Terraform pour $env..."
    terraform plan -out="$env.tfplan"
    
    # Demander confirmation
    echo
    log_warning "Vous êtes sur le point de déployer l'environnement $env."
    read -p "Continuer ? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Déploiement annulé"
        exit 0
    fi
    
    # Apply
    terraform apply "$env.tfplan"
    
    # Nettoyer le plan
    rm -f "$env.tfplan"
    
    log_success "Environnement $env déployé avec succès"
    
    # Afficher les outputs
    log_info "Informations de l'infrastructure déployée:"
    terraform output
    
    cd ../../..
}

# Fonction principale
main() {
    local command=${1:-""}
    local environment=${2:-"stage"}
    
    case $command in
        "bootstrap")
            check_prerequisites
            deploy_bootstrap
            ;;
        "deploy")
            check_prerequisites
            deploy_environment "$environment"
            ;;
        "full")
            check_prerequisites
            deploy_bootstrap
            deploy_environment "$environment"
            ;;
        *)
            echo "Usage: $0 {bootstrap|deploy|full} [environment]"
            echo
            echo "Commandes:"
            echo "  bootstrap          - Déploie l'infrastructure de bootstrap (S3 + DynamoDB)"
            echo "  deploy [env]       - Déploie un environnement (défaut: stage)"
            echo "  full [env]         - Déploie bootstrap + environnement"
            echo
            echo "Exemples:"
            echo "  $0 bootstrap"
            echo "  $0 deploy stage"
            echo "  $0 full stage"
            exit 1
            ;;
    esac
}

# Exécution
main "$@"