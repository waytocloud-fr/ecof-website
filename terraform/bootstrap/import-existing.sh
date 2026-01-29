#!/bin/bash

# Script pour importer les ressources AWS existantes dans Terraform

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

# Vérifier les ressources existantes
check_existing_resources() {
    log_info "Vérification des ressources AWS existantes..."
    
    # Vérifier la table DynamoDB
    if aws dynamodb describe-table --table-name ecof-terraform-locks --region eu-west-3 >/dev/null 2>&1; then
        log_warning "Table DynamoDB 'ecof-terraform-locks' existe déjà"
        DYNAMODB_EXISTS=true
    else
        log_info "Table DynamoDB 'ecof-terraform-locks' n'existe pas"
        DYNAMODB_EXISTS=false
    fi
    
    # Vérifier le bucket state
    if aws s3 ls s3://ecof-terraform-state-secure >/dev/null 2>&1; then
        log_warning "Bucket S3 'ecof-terraform-state-secure' existe déjà"
        S3_STATE_EXISTS=true
    else
        log_info "Bucket S3 'ecof-terraform-state-secure' n'existe pas"
        S3_STATE_EXISTS=false
    fi
    
    # Vérifier le bucket logs
    if aws s3 ls s3://ecof-terraform-logs-secure >/dev/null 2>&1; then
        log_warning "Bucket S3 'ecof-terraform-logs-secure' existe déjà"
        S3_LOGS_EXISTS=true
    else
        log_info "Bucket S3 'ecof-terraform-logs-secure' n'existe pas"
        S3_LOGS_EXISTS=false
    fi
}

# Importer les ressources existantes
import_existing_resources() {
    log_info "Import des ressources existantes dans Terraform..."
    
    if [ "$DYNAMODB_EXISTS" = true ]; then
        log_info "Import de la table DynamoDB..."
        terraform import aws_dynamodb_table.terraform_locks ecof-terraform-locks || {
            log_warning "Échec de l'import DynamoDB (peut-être déjà importé)"
        }
    fi
    
    if [ "$S3_STATE_EXISTS" = true ]; then
        log_info "Import du bucket S3 state..."
        terraform import aws_s3_bucket.terraform_state ecof-terraform-state-secure || {
            log_warning "Échec de l'import S3 state (peut-être déjà importé)"
        }
    fi
    
    if [ "$S3_LOGS_EXISTS" = true ]; then
        log_info "Import du bucket S3 logs..."
        terraform import aws_s3_bucket.terraform_logs ecof-terraform-logs-secure || {
            log_warning "Échec de l'import S3 logs (peut-être déjà importé)"
        }
    fi
}

# Nettoyer et réessayer
clean_and_retry() {
    log_info "Nettoyage et nouvelle tentative..."
    
    # Supprimer les ressources existantes si demandé
    echo
    log_warning "Options disponibles :"
    echo "1. Importer les ressources existantes (recommandé)"
    echo "2. Supprimer les ressources existantes et recréer"
    echo "3. Annuler"
    
    read -p "Choisissez une option (1-3): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            import_existing_resources
            ;;
        2)
            log_warning "Suppression des ressources existantes..."
            if [ "$DYNAMODB_EXISTS" = true ]; then
                aws dynamodb delete-table --table-name ecof-terraform-locks --region eu-west-3
                log_info "Attente de la suppression de la table DynamoDB..."
                aws dynamodb wait table-not-exists --table-name ecof-terraform-locks --region eu-west-3
            fi
            if [ "$S3_STATE_EXISTS" = true ]; then
                aws s3 rb s3://ecof-terraform-state-secure --force
            fi
            if [ "$S3_LOGS_EXISTS" = true ]; then
                aws s3 rb s3://ecof-terraform-logs-secure --force
            fi
            log_success "Ressources supprimées"
            ;;
        3)
            log_info "Opération annulée"
            exit 0
            ;;
        *)
            log_error "Option invalide"
            exit 1
            ;;
    esac
}

# Déployer après import/nettoyage
deploy_after_import() {
    log_info "Déploiement après import/nettoyage..."
    
    # Refresh du state
    terraform refresh
    
    # Nouveau plan
    terraform plan
    
    # Demander confirmation
    echo
    read -p "Appliquer les changements ? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply
        log_success "Déploiement terminé avec succès !"
    else
        log_info "Déploiement annulé"
    fi
}

# Fonction principale
main() {
    log_info "Gestion des ressources AWS existantes pour Terraform..."
    
    # Vérifier les prérequis
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI n'est pas installé"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "Credentials AWS non configurés"
        exit 1
    fi
    
    # Vérifier les ressources existantes
    check_existing_resources
    
    # Si des ressources existent, gérer l'import/suppression
    if [ "$DYNAMODB_EXISTS" = true ] || [ "$S3_STATE_EXISTS" = true ] || [ "$S3_LOGS_EXISTS" = true ]; then
        clean_and_retry
        deploy_after_import
    else
        log_info "Aucune ressource existante détectée"
        log_info "Vous pouvez procéder avec 'terraform apply'"
    fi
}

# Variables globales
DYNAMODB_EXISTS=false
S3_STATE_EXISTS=false
S3_LOGS_EXISTS=false

# Exécution
main "$@"