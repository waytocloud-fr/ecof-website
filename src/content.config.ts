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
  pages,
};