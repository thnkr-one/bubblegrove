const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}',
   // 'node_modules/preline/dist/*.js',
  ],
  theme: {
    extend: {
      colors: {
        customBlue: 'rgb(31, 41, 54)',
        customDarkBlue: 'rgb(17, 24, 38)',
        omegaBaseOne: 'rgb(11,20,38)',
        omegaBaseTwo: 'rgb(30,45,64)',
        omegaBaseThree: 'rgb(169,194,220)',
        omegaBaseThreePastel: 'hsl(210, 30%, 80%)',
        omegaBaseFour: 'rgb(203,218,218)',
        omegaBaseFive: 'rgb(13,13,13)',
        jupiterBaseOne: 'rgb(38,48,59)',
        jupiterBaseTwo: 'rgb(88,102,115)',
        jupiterBaseTwoPastel: 'hsl(210, 10%, 39%)',

        jupiterBaseThree: 'rgb(242,180,126)',
        jupiterBaseFour: 'rgb(217,167,139)',
        jupiterBaseFive: 'rgb(217,204,197)',
      },
      customColors: {
        colorOne: 'rgba(100, 140, 140, 1)',
        'gradient-dark': '#A7B7C5', // Top color, rgb(167, 183, 197)
        'gradient-light': '#D9D6D9', // Bottom color, rgb(217, 214, 217)


      },
      backgroundImage: {
        'custom-gradient': 'linear-gradient(to bottom, #A7B7C5, #D9D6D9)',
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    require('@tailwindcss/aspect-ratio'),
   // require('preline/plugin'),

  ]
}

