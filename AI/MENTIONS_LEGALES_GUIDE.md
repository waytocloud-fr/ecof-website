# Guide d'intégration des mentions légales - ECOF

## 📋 Vue d'ensemble

J'ai créé une structure complète de mentions légales pour le site ECOF, conforme au RGPD et à la législation française.

---

## 🎯 Ce qui a été créé

### 1. Footer (src/components/Footer.astro)
Un footer complet avec :
- **4 colonnes** : À propos, Navigation, Sections, Contact
- **Réseaux sociaux** : Facebook, Instagram
- **Barre de mentions légales** : Liens vers toutes les pages légales
- **Copyright** : Mise à jour automatique de l'année

### 2. Page Mentions légales (/mentions-legales)
Contenu obligatoire :
- ✅ Éditeur du site (association, SIRET, RNA)
- ✅ Hébergement (AWS CloudFront/S3)
- ✅ Propriété intellectuelle
- ✅ Protection des données (RGPD)
- ✅ Cookies
- ✅ Liens hypertextes
- ✅ Limitation de responsabilité
- ✅ Droit applicable
- ✅ Crédits

### 3. Page Politique de confidentialité (/politique-confidentialite)
Conforme RGPD :
- ✅ Responsable du traitement
- ✅ Données collectées (adhésion, navigation, contact, photos)
- ✅ Finalités du traitement
- ✅ Base légale
- ✅ Destinataires des données
- ✅ Durée de conservation (tableau détaillé)
- ✅ Droits des utilisateurs (accès, rectification, effacement, etc.)
- ✅ Sécurité des données
- ✅ Droit de réclamation CNIL

### 4. Page Gestion des cookies (/cookies)
Transparence totale :
- ✅ Explication des cookies
- ✅ Types de cookies (essentiels, performance, réseaux sociaux)
- ✅ Gestion des préférences
- ✅ Instructions par navigateur
- ✅ Cookies tiers

---

## 🔧 Intégration dans le site

### Footer ajouté automatiquement
Le footer est maintenant inclus dans `BaseLayout.astro`, donc il apparaît sur toutes les pages automatiquement.

### Liens créés
- `/mentions-legales` - Mentions légales complètes
- `/politique-confidentialite` - Politique RGPD
- `/cookies` - Gestion des cookies
- `/plan-du-site` - À créer (optionnel)

---

## ⚠️ Informations à compléter

Vous devez remplacer les placeholders suivants :

### Dans tous les fichiers :

1. **Adresse du siège social**
   ```
   Remplacer : [Adresse complète], 42700 Firminy
   Par : Votre adresse réelle
   ```

2. **Numéro RNA (Répertoire National des Associations)**
   ```
   Remplacer : W[XXXXXXXXX]
   Par : Votre numéro RNA (format W + 9 chiffres)
   ```

3. **Numéro SIRET**
   ```
   Remplacer : [XXX XXX XXX XXXXX]
   Par : Votre SIRET (14 chiffres)
   ```

4. **Nom du Président**
   ```
   Remplacer : [Nom du Président]
   Par : Nom complet du président actuel
   ```

5. **Téléphone**
   ```
   Remplacer : 04 XX XX XX XX
   Par : Votre numéro de téléphone réel
   ```

6. **Email**
   ```
   Vérifier : contact@ecof-firminy.fr
   Ou remplacer par votre email réel
   ```

7. **Crédits développement**
   ```
   Remplacer : [Nom du développeur ou agence]
   Par : Votre nom ou celui de votre prestataire
   ```

---

## 📱 Design du Footer

### Structure responsive
- **Desktop** : 4 colonnes
- **Tablet** : 2 colonnes
- **Mobile** : 1 colonne (stack vertical)

### Couleurs
- Background : Gris 900 (#111827)
- Texte : Blanc et Gris 400
- Liens hover : Blanc
- Accent : Rouge 600 (#DC2626)

### Sections
1. **À propos** : Logo, description, réseaux sociaux
2. **Navigation** : Liens principaux
3. **Sections** : Compétition, École, Cyclosport, Loisirs
4. **Contact** : Adresse, email, téléphone avec icônes

---

## 🍪 Gestion des cookies - À implémenter

### Solution recommandée : Tarteaucitron.js
C'est une solution française, gratuite et conforme RGPD.

#### Installation :
```html
<!-- Dans BaseLayout.astro, avant </head> -->
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/tarteaucitronjs@latest/tarteaucitron.min.js"></script>
<script type="text/javascript">
tarteaucitron.init({
  "privacyUrl": "/politique-confidentialite",
  "hashtag": "#cookies",
  "cookieName": "ecof_cookies",
  "orientation": "bottom",
  "groupServices": false,
  "showAlertSmall": true,
  "cookieslist": true,
  "closePopup": false,
  "showIcon": true,
  "iconPosition": "BottomLeft",
  "adblocker": false,
  "DenyAllCta": true,
  "AcceptAllCta": true,
  "highPrivacy": true,
  "handleBrowserDNTRequest": false,
  "removeCredit": false,
  "moreInfoLink": true,
  "useExternalCss": false,
  "readmoreLink": "/cookies",
  "mandatory": true
});
</script>
```

#### Pour Google Analytics (si vous l'utilisez) :
```javascript
tarteaucitron.user.gtagUa = 'UA-XXXXXXXX-X';
(tarteaucitron.job = tarteaucitron.job || []).push('gtag');
```

### Alternatives :
- **Cookiebot** (payant, très complet)
- **OneTrust** (entreprise)
- **Axeptio** (français, design moderne)

---

## ✅ Conformité RGPD - Checklist

### Obligations respectées :
- [x] Information claire sur les données collectées
- [x] Finalités du traitement expliquées
- [x] Base légale identifiée
- [x] Durée de conservation précisée
- [x] Droits des utilisateurs détaillés
- [x] Coordonnées du responsable du traitement
- [x] Information sur le droit de réclamation CNIL
- [x] Politique de cookies transparente

### À faire :
- [ ] Compléter les informations manquantes (SIRET, RNA, etc.)
- [ ] Implémenter une solution de gestion des cookies
- [ ] Créer un registre des traitements (document interne)
- [ ] Former les membres du bureau à la protection des données
- [ ] Mettre en place une procédure pour les demandes d'exercice de droits
- [ ] Vérifier les contrats avec les sous-traitants (FSGT, FFC, assureur)

---

## 📄 Documents complémentaires recommandés

### 1. Registre des traitements (interne)
Document obligatoire listant tous les traitements de données :
- Adhésions
- Licences sportives
- Newsletter
- Photos/vidéos
- Comptabilité

### 2. Formulaire de consentement photos
Pour les événements, créer un formulaire de consentement pour :
- Publication sur le site
- Publication sur les réseaux sociaux
- Utilisation dans les supports de communication

### 3. Procédure d'exercice des droits
Document interne expliquant comment traiter les demandes :
- Vérification de l'identité
- Délai de réponse (1 mois)
- Format de réponse

---

## 🔗 Liens utiles

### Ressources CNIL
- [Guide RGPD pour les associations](https://www.cnil.fr/fr/rgpd-passer-a-laction)
- [Modèles de mentions d'information](https://www.cnil.fr/fr/modeles)
- [Registre des traitements](https://www.cnil.fr/fr/RGDP-le-registre-des-activites-de-traitement)

### Outils gratuits
- [Générateur de mentions légales](https://www.subdelirium.com/generateur-de-mentions-legales/)
- [Tarteaucitron.js](https://tarteaucitron.io/)
- [Modèles CNIL](https://www.cnil.fr/fr/modeles)

---

## 🎨 Personnalisation du Footer

### Modifier les réseaux sociaux
Dans `src/components/Footer.astro`, ligne ~30 :
```astro
<a href="https://facebook.com/votre-page" class="...">
  <!-- Icône Facebook -->
</a>
```

### Ajouter un réseau social
Ajoutez un nouveau lien avec l'icône SVG correspondante :
```astro
<a href="https://twitter.com/votre-compte" class="text-gray-400 hover:text-white transition-colors" aria-label="Twitter">
  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
    <!-- SVG Twitter -->
  </svg>
</a>
```

### Modifier les colonnes
Vous pouvez ajouter/supprimer des colonnes en modifiant la grid :
```astro
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
  <!-- Colonnes -->
</div>
```

---

## 📞 Support

Pour toute question sur l'implémentation :
1. Vérifiez la documentation CNIL
2. Consultez un avocat spécialisé en droit numérique si nécessaire
3. Contactez la CNIL pour des questions spécifiques

---

## 🚀 Prochaines étapes

1. **Immédiat** :
   - [ ] Compléter les informations manquantes
   - [ ] Tester les pages sur mobile/desktop
   - [ ] Vérifier tous les liens

2. **Court terme** :
   - [ ] Implémenter la gestion des cookies
   - [ ] Créer le registre des traitements
   - [ ] Former le bureau

3. **Moyen terme** :
   - [ ] Audit RGPD complet
   - [ ] Mise en place des procédures
   - [ ] Révision annuelle

---

**Version** : 1.0  
**Date** : Février 2026  
**Statut** : Prêt pour production (après complétion des informations)
