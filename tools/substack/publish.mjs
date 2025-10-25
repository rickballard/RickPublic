import { chromium } from "playwright";
import fs from "fs/promises";
import path from "path";
import process from "process";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);
const userDataDir = path.join(__dirname, ".auth");

const [,, slug, repoRootArg] = process.argv;
if (!slug) {
  console.error("Usage: node publish.mjs <slug> [repoRoot]");
  process.exit(1);
}
const repoRoot = repoRootArg || path.join(process.env.HOME || process.env.USERPROFILE, "Documents","GitHub","RickPublic");
const postDir  = path.join(repoRoot, "sotw", slug);
const postMd   = path.join(postDir, "post.md");
const metaJson = path.join(postDir, "meta.json");

const exists = async p => !!(await fs.stat(p).catch(()=>null));
if (!await exists(postMd)) throw new Error(`Missing ${postMd}`);

const md   = await fs.readFile(postMd, "utf8");
const meta = await exists(metaJson) ? JSON.parse(await fs.readFile(metaJson, "utf8")) : {};

const titleFromMd = (md.match(/^#\s+(.+)\s*$/m) || [,""])[1].trim();
const subtitle    = (md.match(/^\*\s*Repackaged.*$/m) || [,""])[0].replace(/^\*|\*$/g,"").trim();

const title = (meta.title || titleFromMd || `SOTW — ${slug}`).slice(0, 120);
const tags  = Array.isArray(meta.tags) ? meta.tags : ["policy","risk","ai","CoCivium","CoSuite"];

const ctx = await chromium.launchPersistentContext(userDataDir, { headless: false });
const page = await ctx.newPage();

// ensure logged in
await page.goto("https://rickpublic.substack.com/publish", { waitUntil: "domcontentloaded" });
try {
  await page.waitForURL(/rickpublic\.substack\.com\/publish/i, { timeout: 10000 });
} catch {
  console.log(">>> Please log in inside this window (Google SSO is fine).");
  await page.waitForURL(/rickpublic\.substack\.com\/publish/i, { timeout: 180000 });
}

// open new draft (try multiple selectors)
const candidates = [
  'text="New post"',
  'role=button[name="New post"]',
  'a[href*="/publish/post"]',
  'a[href*="/publish/new"]'
];
let clicked = false;
for (const sel of candidates) {
  try { await page.click(sel, { timeout: 3000 }); clicked = true; break; } catch {}
}
if (!clicked) {
  await page.goto("https://rickpublic.substack.com/publish/post", { waitUntil: "domcontentloaded" });
}

// fill title
try {
  const titleSel = '[data-testid="editor-title"], [contenteditable="true"] h1, h1[contenteditable="true"]';
  await page.waitForSelector(titleSel, { timeout: 15000 });
  await page.click(titleSel);
  await page.keyboard.press(process.platform === "darwin" ? "Meta+A" : "Control+A");
  await page.keyboard.type(title);
} catch {
  console.warn("Could not auto-fill title; will paste everything into the body instead.");
}

// fill body
const bodySel = '[data-testid="post-editor"] [contenteditable="true"], [contenteditable="true"]';
await page.waitForSelector(bodySel, { timeout: 15000 });
await page.click(bodySel);
const bodyText = (subtitle ? subtitle + "\n\n" : "") + md;
await page.evaluate((txt) => {
  const el = document.querySelector('[data-testid="post-editor"] [contenteditable="true"]') || document.querySelector('[contenteditable="true"]');
  el.focus();
  document.execCommand("insertText", false, txt);
}, bodyText);

// best-effort tags
try {
  const settingsButton = await page.$('button:has-text("Settings"), [aria-label="Settings"]');
  if (settingsButton) await settingsButton.click();
  const tagInput = await page.waitForSelector('input[placeholder*="Add tags"], input[aria-label*="Add tag"]', { timeout: 5000 });
  for (const t of tags) {
    await tagInput.fill(t);
    await page.keyboard.press("Enter");
  }
} catch {
  console.warn("Tagging skipped (selectors changed).");
}

console.log(">>> ✅ Draft prepared in the open window. Review & publish manually when ready.");
