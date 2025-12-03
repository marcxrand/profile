const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = plugin(function ({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../../deps/remixicons/icons");
  let values = {};

  // Read all category directories
  fs.readdirSync(iconsDir).forEach((category) => {
    let categoryPath = path.join(iconsDir, category);
    if (fs.statSync(categoryPath).isDirectory()) {
      fs.readdirSync(categoryPath).forEach((file) => {
        if (file.endsWith(".svg")) {
          let name = path.basename(file, ".svg");
          let fullPath = path.join(categoryPath, file);
          values[name] = { name, fullPath };
          // Make -line variant the default (e.g., "search" maps to "search-line")
          if (name.endsWith("-line")) {
            let baseName = name.slice(0, -5);
            values[baseName] = { name: baseName, fullPath };
          }
        }
      });
    }
  });

  matchComponents(
    {
      remix: ({ name, fullPath }) => {
        let content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "");
        content = encodeURIComponent(content);
        let size = theme("spacing.4");
        return {
          [`--remix-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--remix-${name})`,
          mask: `var(--remix-${name})`,
          "mask-repeat": "no-repeat",
          "background-color": "currentColor",
          "vertical-align": "middle",
          display: "inline-block",
          width: size,
          height: size,
        };
      },
    },
    { values },
  );
});
