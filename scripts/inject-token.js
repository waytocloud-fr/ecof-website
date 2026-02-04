import { readFileSync, writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Chemin vers le fichier admin
const adminPath = join(__dirname, '../dist/admin/index.html');

try {
    // Lire le fichier admin
    let content = readFileSync(adminPath, 'utf8');
    
    // Récupérer les secrets depuis les variables d'environnement
    const token = process.env.CMS_GITHUB_TOKEN;
    const password = process.env.CMS_PASSWORD;
    
    if (token && password) {
        // Remplacer les placeholders par les vraies valeurs
        content = content.replace('COLLE_TON_NOUVEAU_TOKEN_ICI', token);
        content = content.replace('COLLE_TON_MOT_DE_PASSE_ICI', password);
        
        // Écrire le fichier modifié
        writeFileSync(adminPath, content);
        
        console.log('✅ Token GitHub et mot de passe injectés avec succès dans le CMS');
    } else {
        console.log('⚠️ Token GitHub ou mot de passe non trouvé dans les variables d\'environnement');
        console.log(`Token présent: ${!!token}, Mot de passe présent: ${!!password}`);
    }
} catch (error) {
    console.error('❌ Erreur lors de l\'injection des secrets:', error.message);
}