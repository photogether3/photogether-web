module.exports = {
  mode: "jit",
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/assets/stylesheets/**/*.css"
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#00673F",
          '0': "#FFFFFF",
          '5': "#E5F7F0",
          '10': "#CCEEE1",
          '20': "#99DEC3",
          '30': "#66CDA5",
          '40': "#33BD87",
          '50': "#00AC69",
          '60': "#008A54",
          '70': "#00673F",
          '80': "#00452A",
          '90': "#002215",
          '100': "#000000",
        },
        secondary: {
          DEFAULT: "#124734",
          '0': "#FFFFFF",
          '5': "#E7EDEB",
          '10': "#D0DAD6",
          '20': "#A0B5AE",
          '30': "#719185",
          '40': "#416C5D",
          '50': "#124734",
          '60': "#0E392A",
          '70': "#0B2B1F",
          '80': "#071C15",
          '90': "#040E0A",
          '100': "#000000",
        },
        accent: {
          DEFAULT: "#E71825",
          '0': "#FFFFFF",
          '5': "#FDF2F3",
          '10': "#FBD6D8",
          '20': "#F5A3A8",
          '30': "#F1747C",
          '40': "#EC4651",
          '50': "#E71825",
          '60': "#B9131E",
          '70': "#8B0E16",
          '80': "#5C0A0F",
          '90': "#2E0507",
          '100': "#000000",
        },
        waning: {
          DEFAULT: "#FFB724",
          '5': "#FFF9E5",
          '10': "#FFEAC1",
          '50': "#FFB724",
          '60': "#98690A",
        }
      },
    },
  },
  plugins: [
    require('tailwindcss-motion')
  ],
}
