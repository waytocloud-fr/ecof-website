import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  site: 'https://d1zcuce5tj6u3s.cloudfront.net',
  output: 'static',
  build: {
    assets: 'assets'
  },
  integrations: [tailwind()]
});