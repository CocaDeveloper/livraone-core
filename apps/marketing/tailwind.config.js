/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#f0f7ff",
          100: "#e0efff",
          200: "#b9ddff",
          300: "#7fc2ff",
          400: "#3aa0ff",
          500: "#147bff",
          600: "#0b5fe6",
          700: "#0a4bb8",
          800: "#0c3f93",
          900: "#0b326f"
        },
        grass: {
          600: "#3f7f3f",
          700: "#356d35"
        }
      },
      boxShadow: {
        soft: "0 18px 50px rgba(15, 23, 42, 0.12)",
        card: "0 10px 30px rgba(15, 23, 42, 0.10)"
      }
    }
  },
  plugins: []
};
