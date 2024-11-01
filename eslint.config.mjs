import globals from "globals";
import pluginJs from "@eslint/js";

export default [
  {
    files: ["**/*.js"],
    languageOptions: {
      sourceType: "script",
      globals: {
        ...globals.browser,
        ...globals.jquery,
        google: "readonly",
        GWW: "writable"
      }
    }
  },
  pluginJs.configs.recommended
];
