/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      fontFamily: {
        'inter': ['Inter', 'sans-serif'],
      },
      colors: {
        // Couleurs ECOF basées sur le maillot du club
        'ecof': {
          'red': {
            DEFAULT: '#E31E24', // Rouge exact du maillot ECOF
            'light': '#FF4449',
            'dark': '#C41E1A',
          },
          'yellow': {
            DEFAULT: '#FFD700', // Jaune/Or exact du maillot ECOF
            'light': '#FFE44D',
            'dark': '#E6C200',
          },
          'black': {
            DEFAULT: '#1A1A1A', // Noir ECOF
            'light': '#2D2D2D',
          },
          'white': '#FFFFFF',
        }
      },
    },
  },
  plugins: [],
}