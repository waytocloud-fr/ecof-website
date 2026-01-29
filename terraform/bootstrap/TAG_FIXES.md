# Corrections des Tags AWS - Bootstrap

## Problème identifié

L'erreur `InvalidTag: The TagValue you have provided is invalid` indique que certaines valeurs de tags contiennent des caractères non autorisés par AWS S3.

## Règles AWS pour les tags

### Caractères autorisés :
- Lettres (a-z, A-Z)
- Chiffres (0-9)
- Espaces
- Caractères spéciaux : `+ - = . _ : / @`

### Caractères NON autorisés :
- Caractères accentués (é, è, à, ç, etc.)
- Caractères Unicode spéciaux
- Certains caractères de ponctuation

## Corrections apportées

### 1. Default Tags (Providers)
**Avant :**
```hcl
default_tags {
  tags = {
    Project     = "ECOF Website"      # Espace OK
    Purpose     = "State Management"  # Espace OK
  }
}
```

**Après :**
```hcl
default_tags {
  tags = {
    Project     = "ECOF-Website"      # Tiret au lieu d'espace
    Purpose     = "State-Management"  # Tiret au lieu d'espace
  }
}
```

### 2. Descriptions avec caractères spéciaux
**Avant :**
```hcl
Description = "Bucket pour stocker le state Terraform de manière sécurisée"
```

**Après :**
```hcl
Description = "Secure-Terraform-state-storage-bucket"
```

### 3. KMS Key Descriptions
**Avant :**
```hcl
description = "KMS key pour chiffrement du state Terraform ECOF"
```

**Après :**
```hcl
description = "KMS key for ECOF Terraform state encryption"
```

### 4. Cohérence des noms de buckets
**Avant :**
```hcl
bucket = "ecof-terraform-logs"        # Incohérent
bucket = "ecof-terraform-state"       # Incohérent avec backend
```

**Après :**
```hcl
bucket = "ecof-terraform-logs-secure"   # Cohérent
bucket = "ecof-terraform-state-secure"  # Cohérent avec backend
```

## Résumé des changements

### Tags corrigés :
- ✅ Suppression des caractères accentués
- ✅ Remplacement des espaces par des tirets dans les valeurs critiques
- ✅ Utilisation de l'anglais pour éviter les caractères spéciaux
- ✅ Cohérence des noms de ressources

### Ressources affectées :
- `aws_s3_bucket.terraform_state`
- `aws_s3_bucket.terraform_logs`
- `aws_s3_bucket.terraform_state_replica`
- `aws_dynamodb_table.terraform_locks`
- `aws_kms_key.terraform_state`
- `aws_kms_key.terraform_state_replica`
- Providers AWS (default_tags)

## Test des corrections

Après ces corrections, vous pouvez relancer :

```bash
cd terraform/bootstrap
terraform plan
terraform apply
```

Les tags devraient maintenant être acceptés par AWS sans erreur.

## Bonnes pratiques pour les tags

### ✅ Recommandé :
```hcl
tags = {
  Name        = "my-resource-name"
  Environment = "production"
  Project     = "ECOF-Website"
  Owner       = "DevOps-Team"
  CostCenter  = "IT-Department"
}
```

### ❌ À éviter :
```hcl
tags = {
  Name        = "mon-resource-avec-accents"
  Description = "Ressource créée pour l'équipe"
  Propriétaire = "Équipe DevOps"
}
```

## Validation

Pour valider que les tags sont corrects, vous pouvez utiliser :

```bash
# Valider la syntaxe Terraform
terraform validate

# Voir le plan sans appliquer
terraform plan

# Vérifier les tags après création
aws s3api get-bucket-tagging --bucket ecof-terraform-state-secure
```