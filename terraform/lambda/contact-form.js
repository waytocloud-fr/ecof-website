/**
 * AWS Lambda function pour gérer le formulaire de contact
 * Envoie un email via AWS SES
 */

const AWS = require('aws-sdk');
const ses = new AWS.SES({ region: 'eu-west-1' }); // Ajuster la région selon votre configuration

exports.handler = async (event) => {
  // Headers CORS
  const headers = {
    'Access-Control-Allow-Origin': '*', // À restreindre à votre domaine en production
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  // Gérer les requêtes OPTIONS (preflight CORS)
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: '',
    };
  }

  try {
    // Parser le body
    const data = JSON.parse(event.body);
    
    // Validation des données
    if (!data.name || !data.email || !data.subject || !data.message) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: 'Tous les champs obligatoires doivent être remplis',
        }),
      };
    }

    // Validation de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          error: 'Adresse email invalide',
        }),
      };
    }

    // Mapper les sujets
    const subjectMap = {
      'adhesion': 'Adhésion au club',
      'information': 'Demande d\'information',
      'ecole-velo': 'École de vélo',
      'competition': 'Compétition',
      'sortie': 'Sorties et événements',
      'partenariat': 'Partenariat',
      'autre': 'Autre',
    };

    const subjectLabel = subjectMap[data.subject] || data.subject;

    // Préparer l'email
    const params = {
      Source: 'contact@ecofirminy.fr', // Doit être vérifié dans AWS SES
      Destination: {
        ToAddresses: ['contact@ecofirminy.fr'],
      },
      ReplyToAddresses: [data.email],
      Message: {
        Subject: {
          Data: `[Site ECOF] ${subjectLabel} - ${data.name}`,
          Charset: 'UTF-8',
        },
        Body: {
          Html: {
            Data: `
              <!DOCTYPE html>
              <html>
              <head>
                <meta charset="UTF-8">
                <style>
                  body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                  .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                  .header { background-color: #DC2626; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
                  .content { background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
                  .field { margin-bottom: 20px; }
                  .label { font-weight: bold; color: #DC2626; margin-bottom: 5px; }
                  .value { background-color: white; padding: 10px; border-left: 3px solid #DC2626; }
                  .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #666; }
                </style>
              </head>
              <body>
                <div class="container">
                  <div class="header">
                    <h1>Nouveau message depuis le site ECOF</h1>
                  </div>
                  <div class="content">
                    <div class="field">
                      <div class="label">Nom :</div>
                      <div class="value">${escapeHtml(data.name)}</div>
                    </div>
                    
                    <div class="field">
                      <div class="label">Email :</div>
                      <div class="value"><a href="mailto:${escapeHtml(data.email)}">${escapeHtml(data.email)}</a></div>
                    </div>
                    
                    <div class="field">
                      <div class="label">Téléphone :</div>
                      <div class="value">${escapeHtml(data.phone || 'Non renseigné')}</div>
                    </div>
                    
                    <div class="field">
                      <div class="label">Sujet :</div>
                      <div class="value">${escapeHtml(subjectLabel)}</div>
                    </div>
                    
                    <div class="field">
                      <div class="label">Message :</div>
                      <div class="value">${escapeHtml(data.message).replace(/\n/g, '<br>')}</div>
                    </div>
                  </div>
                  <div class="footer">
                    <p>Ce message a été envoyé depuis le formulaire de contact du site ECOF</p>
                    <p>Date : ${new Date().toLocaleString('fr-FR', { timeZone: 'Europe/Paris' })}</p>
                  </div>
                </div>
              </body>
              </html>
            `,
            Charset: 'UTF-8',
          },
          Text: {
            Data: `
Nouveau message depuis le site ECOF

Nom : ${data.name}
Email : ${data.email}
Téléphone : ${data.phone || 'Non renseigné'}
Sujet : ${subjectLabel}

Message :
${data.message}

---
Date : ${new Date().toLocaleString('fr-FR', { timeZone: 'Europe/Paris' })}
            `,
            Charset: 'UTF-8',
          },
        },
      },
    };

    // Envoyer l'email
    await ses.sendEmail(params).promise();

    // Réponse de succès
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        message: 'Message envoyé avec succès',
      }),
    };

  } catch (error) {
    console.error('Erreur:', error);
    
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        error: 'Une erreur est survenue lors de l\'envoi du message',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined,
      }),
    };
  }
};

// Fonction utilitaire pour échapper le HTML
function escapeHtml(text) {
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;',
  };
  return text.replace(/[&<>"']/g, (m) => map[m]);
}
