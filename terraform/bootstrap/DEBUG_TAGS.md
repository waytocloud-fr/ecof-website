# Debug des Tags AWS - Bucket terraform_logs

## Problème persistant

Malgré les corrections des tags, l'erreur `InvalidTag: The TagValue you have provided is invalid` persiste sur le bucket `terraform_logs`.

## Analyse du problème

### Causes possibles :

1. **Cache Terraform** : État intermédiaire corrompu
2. **Conflit tags** : Conflit entre `default_tags` et tags individuels
3. **Caractères invisibles** : Caractères Unicode cachés
4. **Limite de longueur** : Valeurs de tags trop longues
5. **Caractères spéciaux** : Caractères non détectés

### Règles AWS pour les tags S3 :

- **Clé** : 1-128 caractères Unicode UTF-8
- **Valeur** : 0-256 caractères Unicode UTF-8
- **Caractères autorisés** : lettres, chiffres, espaces, `+ - = . _ : / @`
- **Sensible à la casse** : Oui

## Solution de debug appliquée

### Étape 1 : Suppression des tags individuels
```hcl
# AVANT (avec tags individuels)
resource "aws_s3_bucket" "terraform_logs" {
  bucket = "ecof-terraform-logs-secure"
  
  tags = {
    Name        = "ecof-terraform-logs-secure"
    Description = "Bucket-for-Terraform-access-logs"
  }
}

# APRÈS (sans tags individuels)
resource "aws_s3_bucket" "terraform_logs" {
  bucket = "ecof-terraform-logs-secure"
  
  # Seuls les default_tags du provider seront appliqués
}
```

### Étape 2 : Test avec default_tags uniquement
Les `default_tags` du provider qui seront appliqués :
```hcl
default_tags {
  tags = {
    Project     = "ECOF-Website"      # ✅ Pas d'espace
    Environment = "bootstrap"         # ✅ Caractères simples
    ManagedBy   = "Terraform"         # ✅ Caractères simples
    Purpose     = "State-Management"  # ✅ Tiret au lieu d'espace
  }
}
```

## Commandes de test

### 1. Nettoyer le cache Terraform
```bash
cd terraform/bootstrap
rm -rf .terraform/
rm -f .terraform.lock.hcl
terraform init
```

### 2. Valider la configuration
```bash
terraform validate
```

### 3. Voir le plan détaillé
```bash
terraform plan -detailed-exitcode
```

### 4. Test avec un bucket temporaire
Si le problème persiste, créer un bucket de test :
```hcl
resource "aws_s3_bucket" "test_bucket" {
  bucket = "ecof-test-bucket-${random_id.test.hex}"
  
  # Aucun tag pour tester
}

resource "random_id" "test" {
  byte_length = 4
}
```

## Solutions alternatives

### Option 1 : Bucket sans tags personnalisés
```hcl
resource "aws_s3_bucket" "terraform_logs" {
  bucket = "ecof-terraform-logs-secure"
  # Utiliser uniquement les default_tags
}
```

### Option 2 : Tags minimaux
```hcl
resource "aws_s3_bucket" "terraform_logs" {
  bucket = "ecof-terraform-logs-secure"
  
  tags = {
    Name = "logs"  # Tag minimal
  }
}
```

### Option 3 : Désactiver temporairement les default_tags
```hcl
provider "aws" {
  region = "eu-west-3"
  # Commenter temporairement les default_tags
  # default_tags { ... }
}
```

## Diagnostic avancé

### Vérifier les caractères cachés
```bash
# Examiner le fichier pour des caractères invisibles
cat -A terraform/bootstrap/main.tf | grep -n "terraform_logs"

# Vérifier l'encodage
file terraform/bootstrap/main.tf
```

### Tester avec AWS CLI
```bash
# Créer un bucket de test avec AWS CLI
aws s3 mb s3://ecof-test-tags-$(date +%s)

# Tester l'ajout de tags
aws s3api put-bucket-tagging \
  --bucket ecof-test-tags-$(date +%s) \
  --tagging 'TagSet=[{Key=Name,Value=test},{Key=Project,Value=ECOF-Website}]'
```

## Résolution progressive

1. **✅ Étape 1** : Tester sans tags individuels (fait)
2. **⏳ Étape 2** : Si ça marche, réajouter les tags un par un
3. **⏳ Étape 3** : Si ça ne marche pas, problème avec default_tags
4. **⏳ Étape 4** : Nettoyer le cache et réessayer

## Rollback si nécessaire

Si le problème persiste, on peut :
1. Supprimer complètement la réplication cross-region temporairement
2. Créer d'abord l'infrastructure de base
3. Ajouter la réplication dans un deuxième temps

```hcl
# Configuration minimale pour commencer
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ecof-terraform-state-secure"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "ecof-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

Cette approche permettra d'identifier précisément la source du problème.