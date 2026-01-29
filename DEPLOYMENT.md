# Guide de Déploiement ECOF Website avec OIDC

## Configuration GitHub Actions avec OIDC

### 1. Secret GitHub requis

Pour que le pipeline fonctionne avec OIDC, tu dois ajouter ce secret dans GitHub :

**Aller dans : Settings → Secrets and variables → Actions → New repository secret**

#### Secret requis :
- `AWS_ROLE_ARN` : ARN du rôle IAM pour GitHub Actions

Exemple : `arn:aws:iam::123456789012:role/GitHubActionsRole`

### 2. Configuration de l'environnement GitHub

#### Créer l'environnement "stage" :
1. Aller dans **Settings → Environments**
2. Créer un nouvel environnement : `stage`
3. Configurer les règles de protection :
   - **Deployment branches** : `main` seulement
   - **Required reviewers** : optionnel

### 3. Vérifier la configuration OIDC AWS

#### Le provider OIDC doit exister :
```bash
aws iam list-open-id-connect-providers
```

#### Le rôle IAM doit avoir la trust policy :
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/ecof-website:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### 4. Vérifier les noms de ressources

Dans le fichier `.github/workflows/deploy-stage.yml`, vérifier :

```yaml
# Ligne 58 : Nom du bucket S3
S3_BUCKET="ecof-website-stage-6e85ed80"

# Ligne 72 : ID de distribution CloudFront  
DISTRIBUTION_ID="d1zcuce5tj6u3s"
```

### 5. Test du pipeline

#### Pipeline avec OIDC :
Le pipeline va :
1. ✅ Build le site Astro
2. ✅ Vérifier l'identité AWS avec OIDC
3. ✅ Déployer vers S3
4. ✅ Invalider le cache CloudFront

## Avantages d'OIDC vs Clés d'accès

### 🔒 **Sécurité renforcée**
- **Pas de clés permanentes** stockées dans GitHub
- **Tokens temporaires** générés à la demande
- **Permissions granulaires** par repository/branche

### ⚡ **Gestion simplifiée**
- **Pas de rotation** de clés d'accès
- **Audit trail** complet dans CloudTrail
- **Révocation facile** via IAM

## Commandes manuelles de déploiement

Si le pipeline ne fonctionne pas, tu peux déployer manuellement :

```bash
# 1. Build le site
npm run build

# 2. Déployer vers S3 (avec ton profil AWS local)
aws s3 sync dist/ s3://ecof-website-stage-6e85ed80 --delete

# 3. Invalider CloudFront
aws cloudfront create-invalidation \
  --distribution-id d1zcuce5tj6u3s \
  --paths "/*"
```

## Dépannage OIDC

### Erreur : "No valid credential sources found"
- ✅ Vérifier que le provider OIDC existe
- ✅ Vérifier l'ARN du rôle dans les secrets GitHub
- ✅ Vérifier la trust policy du rôle IAM

### Erreur : "Access Denied"
- ✅ Vérifier les permissions du rôle IAM
- ✅ Vérifier la condition `sub` dans la trust policy
- ✅ Vérifier que le repository/branche correspond

### Erreur : "AssumeRoleWithWebIdentity failed"
- ✅ Vérifier que l'environnement "stage" existe
- ✅ Vérifier les permissions `id-token: write` dans le workflow

## Pipeline actuel avec OIDC

Le pipeline fait :
- **Build** : Compile le site Astro
- **Test** : Vérifie TypeScript (optionnel)
- **Deploy** : 
  1. Assume le rôle IAM via OIDC
  2. Vérifie l'identité AWS
  3. Upload vers S3 avec cache optimisé
  4. Invalide CloudFront

**Sécurité** : Aucune clé permanente, tokens temporaires uniquement !

## Test rapide

Pour tester le pipeline :

```bash
# Faire un petit changement et commit
echo "<!-- Test OIDC -->" >> src/pages/index.astro
git add .
git commit -m "Test OIDC deployment pipeline"
git push origin main
```

Le pipeline va se déclencher automatiquement ! 🚀