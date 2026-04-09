#!/usr/bin/env node
/**
 * check-skill-refs.js
 *
 * Scans all Markdown files in the repository for references to Toji skills
 * and verifies that each referenced skill has a corresponding SKILL.md on disk.
 *
 * A "skill reference" is any pattern matching:
 *   `.github/skills/<name>/SKILL.md`
 *
 * Usage:
 *   node scripts/check-skill-refs.js
 *   node scripts/check-skill-refs.js --verbose
 *
 * Exit codes:
 *   0 — All referenced skills exist on disk (or no references found)
 *   1 — One or more phantom references detected
 */

const fs = require('fs');
const path = require('path');

const VERBOSE = process.argv.includes('--verbose');

// ──────────────────────────────────────────────────────────────────────────────
// Configuration
// ──────────────────────────────────────────────────────────────────────────────

const REPO_ROOT = path.resolve(__dirname, '..');
const SKILLS_DIR = path.join(REPO_ROOT, '.github', 'skills');

/** Directories to exclude when scanning for Markdown files */
const EXCLUDED_DIRS = new Set([
  'node_modules',
  '.git',
  'vendor',
  'dist',
  'build',
  '.next',
]);

// ──────────────────────────────────────────────────────────────────────────────
// Utilities
// ──────────────────────────────────────────────────────────────────────────────

/**
 * Recursively collect all *.md files under a directory,
 * skipping entries listed in EXCLUDED_DIRS.
 */
function collectMarkdownFiles(dir, results = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return results; // unreadable directory — skip silently
  }
  for (const entry of entries) {
    if (EXCLUDED_DIRS.has(entry.name)) continue;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      collectMarkdownFiles(fullPath, results);
    } else if (entry.isFile() && entry.name.endsWith('.md')) {
      results.push(fullPath);
    }
  }
  return results;
}

/**
 * Extract all skill name references from a file's content.
 * Matches strings of the form `.github/skills/<name>/SKILL.md`
 * where <name> contains only word characters and hyphens.
 */
function extractSkillRefs(content) {
  const pattern = /\.github\/skills\/([\w-]+)\/SKILL\.md/g;
  const refs = new Set();
  let match;
  while ((match = pattern.exec(content)) !== null) {
    refs.add(match[1]); // capture group 1 = skill name
  }
  return refs;
}

/**
 * Return the set of skill names that exist on disk under .github/skills/.
 */
function getExistingSkills() {
  const existing = new Set();
  if (!fs.existsSync(SKILLS_DIR)) return existing;
  try {
    for (const entry of fs.readdirSync(SKILLS_DIR, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const skillFile = path.join(SKILLS_DIR, entry.name, 'SKILL.md');
      if (fs.existsSync(skillFile)) {
        existing.add(entry.name);
      }
    }
  } catch {
    // ignore — will surface as phantom refs below
  }
  return existing;
}

// ──────────────────────────────────────────────────────────────────────────────
// Main
// ──────────────────────────────────────────────────────────────────────────────

function main() {
  const markdownFiles = collectMarkdownFiles(REPO_ROOT);
  const existingSkills = getExistingSkills();

  /** Map of skill name → Set of files that reference it */
  const allRefs = new Map();

  for (const filePath of markdownFiles) {
    const content = fs.readFileSync(filePath, 'utf8');
    const refs = extractSkillRefs(content);
    for (const ref of refs) {
      if (!allRefs.has(ref)) allRefs.set(ref, new Set());
      allRefs.get(ref).add(path.relative(REPO_ROOT, filePath));
    }
  }

  const phantoms = [];
  const verified = [];

  for (const [skillName, sourceFiles] of allRefs) {
    if (existingSkills.has(skillName)) {
      verified.push({ skillName, sourceFiles });
    } else {
      phantoms.push({ skillName, sourceFiles });
    }
  }

  // ── Output ─────────────────────────────────────────────────────────────────

  if (VERBOSE) {
    console.log(`\nScanned ${markdownFiles.length} Markdown files`);
    console.log(`Found ${allRefs.size} unique skill reference(s)\n`);

    if (verified.length > 0) {
      console.log('✅ Verified skill references:');
      for (const { skillName, sourceFiles } of verified) {
        console.log(`   ${skillName}`);
        for (const f of sourceFiles) {
          console.log(`     - ${f}`);
        }
      }
      console.log();
    }
  }

  if (phantoms.length > 0) {
    console.error('❌ Phantom skill references detected:\n');
    for (const { skillName, sourceFiles } of phantoms) {
      console.error(`   MISSING: .github/skills/${skillName}/SKILL.md`);
      console.error(`   Referenced in:`);
      for (const f of sourceFiles) {
        console.error(`     - ${f}`);
      }
      console.error();
    }
    console.error(
      `${phantoms.length} phantom reference(s) found. ` +
      `Create the missing SKILL.md files or remove the stale references.`
    );
    process.exit(1);
  }

  const count = verified.length;
  console.log(
    `✅ All ${count} skill reference(s) verified — no phantoms found.`
  );
  process.exit(0);
}

main();
