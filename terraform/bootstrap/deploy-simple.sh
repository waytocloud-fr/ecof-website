#!/bin/bash

# Script de déploiement simplifié pour éviter les erreurs de tags et réplication

set -euo pipefail

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform n'est pas installé"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI n'est pas installé"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "Credentials AWS non configurés ou invalides"
        exit 1
    fi
    
    log_success "Prérequis validés"
}

# Sauvegarde de l'ancien fichier
backup_original() {
    if [ -f "main.tf" ]; then
        log_info "Sauvegarde de main.tf vers main-original.tf"
        cp main.tf main-original.tf
    fi
    
    if [ -f "outputs.tf" ]; then
        log_info "Sauvegarde de outputs.tf vers outputs-original.tf"
        cp outputs.tf outputs-original.tf
    fi
}

# Utilisation de la version simplifiée
use_simple_version() {
    log_info "Utilisation de la version simplifiée..."
    
    # Copier les fichiers simplifiés
    cp main-simple.tf main.tf
    cp outputs-simple.tf outputs.tf
    
    log_success "Version simplifiée activée"
}

# Déploiement
deploy() {
    log_info "Déploiement de l'infrastructure bootstrap simplifiée..."
    
    # Nettoyer le cache si nécessaire
    if [ -d ".terraform" ]; then
        log_info "Nettoyage du cache Terraform..."
        rm -rf .terraform/
        rm -f .terraform.lock.hcl
    fi
    
    # Initialisation
    terraform init
    
    # Validation
    terraform validate
    
    # Plan
    log_info "Génération du plan Terraform..."
    terraform plan -out=bootstrap-simple.tfplan
    
    # Demander confirmation
    echo
    log_warning "Vous êtes sur le point de créer l'infrastructure bootstrap simplifiée."
    log_warning "Cette version n'inclut pas la réplication cross-region."
    read -p "Continuer ? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Déploiement annulé"
        exit 0
    fi
    
    # Apply
    terraform apply bootstrap-simple.tfplan
    
    # Nettoyer le plan
    rm -f bootstrap-simple.tfplan
    
    log_success "Bootstrap simplifié déployé avec succès"
    
    # Afficher les outputs
    log_info "Informations du backend créé:"
    terraform output
}

# Restauration de la version originale
restore_original() {
    if [ -f "main-original.tf" ]; then
        log_info "Restauration de la version originale..."
        cp main-original.tf main.tf
        cp outputs-original.tf outputs.tf
        log_success "Version originale restaurée"
    fi
}

# Fonction principale
main() {
    local command=${1:-"deploy"}
    
    case $command in
        "deploy")
            check_prerequisites
            backup_original
            use_simple_version
            deploy
            ;;
        "restore")
            restore_original
            ;;
        *)
            echo "Usage: $0 {deploy|restore}"
            echo
            echo "Commandes:"
            echo "  deploy   - Déploie la version simplifiée du bootstrap"
            echo "  restore  - Restaure la version originale"
            exit 1
            ;;
    esac
}

# Exécution
main "$@"