# Mentions légales - ECOF (Association sportive)

## ✅ Ce qui a été créé

### 1. Footer simplifié
- Informations du club
- Navigation rapide
- Contact
- Réseaux sociaux
- Lien vers mentions légales uniquement

### 2. Page Mentions légales complète
Adaptée pour une association sportive :
- ✅ Informations sur l'association (SIRET, RNA)
- ✅ Hébergement (AWS)
- ✅ Propriété intellectuelle
- ✅ Protection des données (simplifiée pour association)
- ✅ Pas de cookies (site statique)
- ✅ Responsabilité
- ✅ Droit applicable

---

## 📋 Contenu des mentions légales

### Pour une association sportive, les mentions légales doivent contenir :

#### 1. **Identification de l'association** ✅
- Nom complet : Étoile Cycliste Ouvrière de Firminy
- Forme juridique : Association loi 1901
- Siège social : [À compléter]
- Numéro RNA (W + 9 chiffres) : [À compléter]
- Numéro SIRET (si vous en avez un) : [À compléter]
- Directeur de publication : Le Président

#### 2. **Hébergement** ✅
- Nom de l'hébergeur : AWS
- Coordonnées complètes

#### 3. **Propriété intellectuelle** ✅
- Droits sur le contenu
- Droits sur les photos
- Conditions d'utilisation

#### 4. **Données personnelles** ✅
Version simplifiée car :
- Pas de formulaire en ligne
- Pas de cookies
- Pas de tracking
- Données collectées uniquement en physique (adhésions)

#### 5. **Responsabilité** ✅
- Limitation de responsabilité
- Liens externes

---

## ⚠️ Informations à compléter

### Dans `src/pages/mentions-legales.astro` :

1. **Adresse du siège social**
   ```
   Ligne ~20 : [Adresse complète], 42700 Firminy
   ```

2. **Numéro RNA** (obligatoire pour les associations)
   ```
   Ligne ~22 : W[XXXXXXXXX]
   Format : W suivi de 9 chiffres
   Exemple : W421234567
   ```
   > Où le trouver ? Sur votre récépissé de déclaration en préfecture

3. **Numéro SIRET** (si vous en avez un)
   ```
   Ligne ~23 : [XXX XXX XXX XXXXX]
   Format : 14 chiffres
   ```
   > Certaines associations n'ont pas de SIRET, c'est normal

4. **Nom du Président**
   ```
   Ligne ~26 : [Nom du Président]
   ```

5. **Téléphone**
   ```
   Ligne ~25 : 04 XX XX XX XX
   ```

6. **Email**
   ```
   Ligne ~24 : contact@ecof-firminy.fr
   Vérifier ou remplacer
   ```

---

## 🎯 Spécificités pour une association sportive

### Ce qui est différent d'un site commercial :

1. **Pas de cookies nécessaires**
   - Site statique = pas de tracking
   - Pas de publicité
   - Pas d'analytics (ou anonymisé)
   - ✅ Aucune bannière de cookies nécessaire

2. **Données personnelles simplifiées**
   - Collecte uniquement lors de l'adhésion physique
   - Pas de formulaire en ligne
   - Gestion manuelle (fichier Excel/papier)
   - Obligations RGPD allégées

3. **Pas de CGV/CGU**
   - Pas de vente en ligne
   - Pas de service commercial
   - Juste des mentions légales

4. **Obligations légales minimales**
   - Identification de l'association
   - Hébergeur
   - Directeur de publication
   - C'est tout !

---

## 📝 Obligations RGPD pour une association sportive

### Ce que vous devez faire :

#### 1. **Registre des traitements** (document interne)
Liste simple des données que vous collectez :

```
Traitement : Gestion des adhésions
- Données : Nom, prénom, date de naissance, adresse, téléphone, email
- Finalité : Gestion des membres, licences, assurances
- Base légale : Exécution du contrat d'adhésion
- Durée : Durée de l'adhésion + 3 ans
- Destinataires : Bureau de l'association, FSGT, FFC, assureur
```

#### 2. **Information des membres**
Lors de l'adhésion, informer sur :
- Quelles données sont collectées
- Pourquoi (licences, assurances, communication)
- Combien de temps elles sont conservées
- Leurs droits (accès, rectification, suppression)

#### 3. **Sécurité des données**
- Fichier Excel protégé par mot de passe
- Ou armoire fermée à clé pour les dossiers papier
- Accès limité au bureau

#### 4. **Répondre aux demandes**
Si un membre demande :
- Accès à ses données → Lui fournir une copie
- Rectification → Corriger les erreurs
- Suppression → Supprimer (sauf obligations légales)
- Délai : 1 mois maximum

---

## 📄 Documents recommandés (en plus du site)

### 1. Formulaire d'adhésion papier
Ajouter une mention :
```
Les informations recueillies sont nécessaires à votre adhésion et à la 
gestion de votre licence sportive. Elles sont destinées au bureau de 
l'ECOF, à la FSGT/FFC et à notre assureur. Conformément à la loi 
Informatique et Libertés, vous disposez d'un droit d'accès, de 
rectification et de suppression de vos données en contactant : 
contact@ecof-firminy.fr
```

### 2. Autorisation de droit à l'image (pour les photos)
```
J'autorise l'ECOF à utiliser mon image (photos/vidéos) prises lors des 
événements du club pour :
☐ Le site internet
☐ Les réseaux sociaux
☐ Les supports de communication (affiches, flyers)

Cette autorisation est révocable à tout moment.
```

### 3. Registre des traitements (interne)
Document simple listant :
- Adhésions
- Licences
- Photos
- Comptabilité

---

## ✅ Checklist de conformité

### Mentions légales :
- [ ] Nom de l'association
- [ ] Adresse du siège
- [ ] Numéro RNA
- [ ] Nom du président
- [ ] Hébergeur
- [ ] Contact

### Protection des données :
- [ ] Information sur les données collectées
- [ ] Finalités expliquées
- [ ] Droits des membres mentionnés
- [ ] Registre des traitements créé (interne)
- [ ] Procédure pour répondre aux demandes

### Site web :
- [ ] Pas de cookies = pas de bannière nécessaire
- [ ] Mentions légales accessibles
- [ ] Contact visible

---

## 🚫 Ce que vous N'AVEZ PAS besoin de faire

Pour un site statique d'association sportive :

❌ Bannière de cookies (pas de cookies)  
❌ Politique de cookies détaillée  
❌ CGV/CGU (pas de vente)  
❌ DPO obligatoire (sauf si > 250 salariés)  
❌ Analyse d'impact (AIPD) sauf cas particuliers  
❌ Déclaration CNIL (supprimée depuis le RGPD)  

---

## 📞 Ressources utiles

### CNIL - Associations
- [Guide RGPD pour les associations](https://www.cnil.fr/fr/rgpd-passer-a-laction)
- [Modèle de registre simplifié](https://www.cnil.fr/fr/RGDP-le-registre-des-activites-de-traitement)
- Téléphone : 01 53 73 22 22

### Préfecture
- Pour obtenir votre numéro RNA
- Pour toute modification des statuts

### Fédérations sportives
- FSGT : Obligations spécifiques licences
- FFC : Idem

---

## 🎯 En résumé

Pour l'ECOF, association sportive avec site statique :

### ✅ Obligatoire :
1. Mentions légales sur le site (fait ✅)
2. Information des membres sur leurs données
3. Registre des traitements (document interne simple)
4. Sécuriser les données (fichier protégé)

### ❌ Pas nécessaire :
1. Bannière de cookies
2. Politique de cookies
3. CGV/CGU
4. DPO

### 📝 À faire maintenant :
1. Compléter les infos dans mentions-legales.astro
2. Créer un registre des traitements simple (Excel)
3. Ajouter une mention sur le formulaire d'adhésion papier
4. C'est tout !

---

**Version** : 1.0 - Simplifiée pour association sportive  
**Date** : Février 2026  
**Statut** : Prêt pour production
