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

const sorties = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.date(),
    distance: z.string(),
    difficulty: z.string(),
    description: z.string(),
    image: z.string().optional(),
    startTime: z.string().optional(),
    startLocation: z.string().optional(),
  }),
});

const resultats = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.date(),
    epreuve: z.string(),
    lieu: z.string().optional(),
    distance: z.string().optional(),
    categorie: z.string().optional(),
    description: z.string().optional(),
    images: z.array(z.string()).optional(),
    participants: z.array(z.object({
      nom: z.string(),
      position: z.number().optional(),
      temps: z.string().optional(),
      categorie: z.string().optional(),
      commentaire: z.string().optional(),
    })),
  }),
});

const evenements = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.date(),
    heure: z.string().optional(),
    type: z.string(), // "ecole-velo", "sortie-club", "competition", "reunion", etc.
    lieu: z.string().optional(),
    distance: z.string().optional(),
    difficulte: z.string().optional(),
    description: z.string(),
    image: z.string().optional(),
    lien: z.string().optional(),
    inscriptionRequise: z.boolean().optional(),
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
  sorties,
  resultats,
  evenements,
  pages,
};