// Crawls the built site for every *.html file, screenshots each page with
// Playwright, and writes a manifest the workflow uses to build a PR comment.
import { chromium } from "playwright";
import { readdirSync, statSync, mkdirSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";

const SITE_DIR = process.env.SITE_DIR ?? "public";
const BASE_URL = process.env.BASE_URL ?? "http://localhost:8080";
const OUT_DIR = process.env.OUT_DIR ?? "screenshots";

function findHtmlFiles(dir, files = []) {
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      findHtmlFiles(full, files);
    } else if (entry.endsWith(".html")) {
      files.push(full);
    }
  }
  return files;
}

function toUrlPath(htmlFile) {
  const rel = relative(SITE_DIR, htmlFile).replace(/\\/g, "/");
  if (rel === "index.html") return "/";
  if (rel.endsWith("/index.html")) return "/" + rel.slice(0, -"index.html".length);
  return "/" + rel;
}

function toSlug(urlPath) {
  if (urlPath === "/") return "index";
  return urlPath.replace(/^\/|\/$/g, "").replace(/\//g, "-");
}

const htmlFiles = findHtmlFiles(SITE_DIR).sort();
if (htmlFiles.length === 0) {
  throw new Error(`No .html files found under ${SITE_DIR}`);
}
mkdirSync(OUT_DIR, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });

const results = [];
for (const file of htmlFiles) {
  const urlPath = toUrlPath(file);
  const slug = toSlug(urlPath);
  const outFile = join(OUT_DIR, `${slug}.png`);
  const url = new URL(urlPath, BASE_URL).toString();
  console.log(`Screenshotting ${url} -> ${outFile}`);
  await page.goto(url, { waitUntil: "networkidle" });
  await page.screenshot({ path: outFile, fullPage: true });
  results.push({ urlPath, slug, file: `${slug}.png` });
}

await browser.close();
writeFileSync(join(OUT_DIR, "manifest.json"), JSON.stringify(results, null, 2));
console.log(`Wrote ${results.length} screenshots to ${OUT_DIR}`);
