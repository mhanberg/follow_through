const plugins = [
  require("tailwindcss")("./tailwind.js"),
  require("autoprefixer")
];

if (process.env.NODE_ENV === "production") {
  plugins.push(
    require("postcss-purgecss")({
      content: ['../**/*.html.eex']
    })
  );
}

module.exports = {
  plugins: plugins
};

