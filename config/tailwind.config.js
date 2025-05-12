// // const defaultTheme = require('tailwindcss/defaultTheme')

import forms from '@tailwindcss/forms';
import aspectRatio from '@tailwindcss/aspect-ratio';
import typography from '@tailwindcss/typography';
import containerQueries from '@tailwindcss/container-queries';
import colors from 'tailwindcss/colors';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
    './app/assets/stylesheets/**/*.css',
    './app/assets/tailwind/**/*.css'
  ],
  theme: {
    extend: {
      colors: {
        transparent: 'transparent',
        current: 'currentColor',
        black: colors.black,
        white: colors.white,
        gray: colors.gray,
        blue: colors.blue,
        red: colors.red,
        yellow: colors.yellow,
        green: colors.green,
        indigo: colors.indigo,
        purple: colors.purple,
        pink: colors.pink
      }
    }
  },
  plugins: [
    forms,
    aspectRatio,
    typography,
    containerQueries
  ]
} 