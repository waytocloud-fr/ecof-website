# Guide de Déploiement ECOF Website

## Configuration GitHub Actions

### 1. Secrets GitHub à configurer

Pour que le pipeline fonctionne, tu dois ajouter ces secrets dans GitHub :

**Aller dans : Settings → Secrets and variables → Actions → New repository secret**

#### Secrets requis :
- `AWS_ACCESS_KEY_ID` : Clé d'accès AWS
- `AWS_SECRET_ACCESS_KEY` : Clé secrète AWS

### 2. Comment obtenir les clés AWS

#### Option A : Utiliser un utilisateur IAM existant
```bash
# Si tu as déjà configuré AWS CLI
aws configure list
```

#### Option B : Créer un nouvel utilisateur IAM
1. Aller dans AWS Console → IAM → Users
2. Créer un nouvel utilisateur : `github-actions-ecof`
3. Attacher les politiques :
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`
4. Créer des clés d'accès
5. Copier les clés dans les secrets GitHub

### 3. Vérifier les noms de ressources

Dans le fichier `.github/workflows/deploy-stage.yml`, vérifier :

```yaml
# Ligne 54 : Nom du bucket S3
S3_BUCKET="ecof-website-stage-6e85ed80"

# Ligne 63 : ID de distribution CloudFront  
DISTRIBUTION_ID="d1zcuce5tj6u3s"
```

### 4. Test du pipeline

#### Pipeline simple (sans AWS) :
Le pipeline va :
1. ✅ Build le site Astro
2. ✅ Vérifier TypeScript
3. ❌ Skip le déploiement AWS (si pas de secrets)

#### Pipeline complet (avec AWS) :
Le pipeline va :
1. ✅ Build le site Astro
2. ✅ Déployer vers S3
3. ✅ Invalider le cache CloudFront

## Commandes manuelles de déploiement

Si le pipeline ne fonctionne pas, tu peux déployer manuellement :

```bash
# 1. Build le site
npm run build

# 2. Déployer vers S3
aws s3 sync dist/ s3://ecof-website-stage-6e85ed80 --delete

# 3. Invalider CloudFront
aws cloudfront create-invalidation \
  --distribution-id d1zcuce5tj6u3s \
  --paths "/*"
```

## Dépannage

### Erreur : "Access Denied"
- Vérifier les secrets GitHub
- Vérifier les permissions IAM

### Erreur : "Bucket not found"
- Vérifier le nom du bucket dans le workflow
- Vérifier que le bucket existe

### Erreur : "Distribution not found"
- Vérifier l'ID CloudFront dans le workflow

## Pipeline actuel

Le pipeline simplifié fait :
- **Build** : Compile le site Astro
- **Test** : Vérifie TypeScript (optionnel)
- **Deploy** : Upload vers S3 + invalidation CloudFront (seulement sur main)

C'est beaucoup plus simple que l'ancien pipeline avec Terraform !