const defaultTheme = require("tailwindcss/defaultTheme")
module.exports = {

  content: ["./pages/**/*.{html,js}", "./components/**/*.{html,js}"],
  theme: {
   
    extend: {
      flex: {
        "2": "2 2 0%",
        "3": "3 3 0%",
        "4": "4 4 0%"
      },
      maxWidth: {
        "8xl": "1920px",
      },
    },
  },
  variants: {
    extend: {
      opacity: ["disabled"],
      cursor: ["disabled"],
    },
  },

  plugins: [],
};
