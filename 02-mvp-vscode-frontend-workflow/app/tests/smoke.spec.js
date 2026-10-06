import { test, expect } from "@playwright/test";

test("serves the MVP frontend from the remote workspace", async ({ request }) => {
  const response = await request.get("http://127.0.0.1:3000/");
  expect(response.ok()).toBeTruthy();
  const html = await response.text();
  expect(html).toContain("MVP VS Code Lab");

  const bundle = await request.get("http://127.0.0.1:3000/bundle.js");
  expect(bundle.ok()).toBeTruthy();
  expect(await bundle.text()).toContain("MVP VS Code Frontend Workflow");
});
