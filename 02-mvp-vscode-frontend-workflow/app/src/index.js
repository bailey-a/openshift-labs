import "./styles.css";

const app = document.querySelector("#app");

app.innerHTML = `
  <section class="card">
    <p class="eyebrow">OpenShift / Dev Spaces lab 02</p>
    <h1>MVP VS Code Frontend Workflow</h1>
    <p>This page was built and served inside the remote UDI developer workspace.</p>
    <dl>
      <div><dt>Node</dt><dd>selected with NVM from .nvmrc</dd></div>
      <div><dt>Packages</dt><dd>pnpm</dd></div>
      <div><dt>Build</dt><dd>Rspack</dd></div>
      <div><dt>Lint</dt><dd>ESLint</dd></div>
      <div><dt>Test</dt><dd>Playwright</dd></div>
    </dl>
  </section>
`;
