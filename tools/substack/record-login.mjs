import { chromium } from "playwright";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __filename  = fileURLToPath(import.meta.url);
const __dirname   = path.dirname(__filename);
const userDataDir = path.join(__dirname, ".auth");

async function launchCtx() {
  const opts = { headless: false, args: ["--disable-session-crashed-bubble"] };
  try { return await chromium.launchPersistentContext(userDataDir, { ...opts, channel: "chrome" }); }
  catch { return await chromium.launchPersistentContext(userDataDir, opts); }
}

const ctx  = await launchCtx();
const page = await ctx.newPage();

console.log(">>> A Chrome window opened. Don’t close it.");
console.log(">>> If you see an email box, enter your Gmail and the 6-digit code.");
console.log(">>> If you see the public site with a 'Dashboard' button, you're already logged in.");

await page.goto("https://rickpublic.substack.com/sign-in", { waitUntil: "domcontentloaded" });

const deadline = Date.now() + 180000; // 3 minutes
while (Date.now() < deadline) {
  const url = page.url();
  if (/rickpublic\.substack\.com\/publish/i.test(url)) break;

  const dashBtn = await page.$('a:has-text("Dashboard")');
  if (dashBtn) { await dashBtn.click().catch(()=>{}); }

  await page.waitForTimeout(3000);
}

if (/rickpublic\.substack\.com\/publish/i.test(page.url())) {
  await fs.writeFile(path.join(userDataDir, "LOGIN_OK.txt"), new Date().toISOString(), "utf8");
  console.log(">>> ✅ Session saved. Closing window…");
  await ctx.close();
} else {
  console.log(">>> Still not on Dashboard. Leave the window open, finish auth, then re-run this script.");
}
