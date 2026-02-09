import { defineCollection, z } from 'astro:content';

const actualites = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    pubDate: z.date(),
    author: z.string().optional(),
    description: z.string(),
    image: z.string().optional(),
    tags: z.array(z.string()).optional(),
  }),
});

const resultats = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    pubDate: z.date(), // Harmonisé avec actualités
    epreuve: z.string(),
    lieu: z.string().optional(),
    categorie: z.string().optional(),
    description: z.string().optional(),
    images: z.array(z.string()).optional(),
  }),
});

const evenements = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    pubDate: z.date(), // Harmonisé avec actualités
    heure: z.string().optional(),
    type: z.enum([
      'ecole-velo',
      'sortie-club', 
      'sortie',
      'competition',
      'course',
      'reunion',
      'assemblee-generale',
      'formation',
      'entrainement',
      'evenement-special',
      'randonnee',
      'cyclosport',
      'vtt',
      'piste',
      'route'
    ]), // Types d'événements avec couleurs différentes
    lieu: z.string().optional(),
    description: z.string(),
    image: z.string().optional(),
    lien: z.string().optional(),
    contact: z.string().optional(),
  }),
});

const pages = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string().optional(),
  }),
});

export const collections = {
  actualites,
  resultats,
  evenements,
  pages,
};