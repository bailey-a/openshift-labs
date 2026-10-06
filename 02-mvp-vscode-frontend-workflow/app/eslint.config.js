export default [
  {
    ignores: ["dist/**", "playwright-report/**", "test-results/**"]
  },
  {
    files: ["src/**/*.js", "tests/**/*.js"],
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "module",
      globals: {
        document: "readonly",
        process: "readonly"
      }
    },
    rules: {
      "no-undef": "error",
      "no-unused-vars": "error"
    }
  }
];
