#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const {
  bumpVersion,
  isDocumentationUpdateRequired,
  createKeepAChangelogEntry,
} = require('./release-utils');

const ROOT = path.resolve(__dirname, '..', '..');
const VERSION_FILE = path.join(ROOT, '.github', 'toji-version.json');
const CHANGELOG_FILE = path.join(ROOT, 'CHANGELOG.md');
const CHANGELOG_ENTRIES_MARKER = '<!-- changelog-entries -->';

const CHANGELOG_HEADER = [
  '# Changelog',
  '',
  'All notable changes to this project will be documented in this file.',
  '',
  'The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),',
  'and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).',
  '',
  '## [Unreleased]',
  '',
  '### Added',
  '- None',
  '',
  '### Changed',
  '- None',
  '',
  '### Fixed',
  '- None',
  '',
  CHANGELOG_ENTRIES_MARKER,
  '',
].join('\n');

function usage() {
  console.log('Usage: node scripts/release/prepare-release.js --bump <major|minor|patch> [--summary "text"]');
}

function parseArgs(argv) {
  const args = {
    bump: null,
    summary: '',
  };

  for (let i = 0; i < argv.length; i += 1) {
    const current = argv[i];

    if (current === '--bump') {
      args.bump = argv[i + 1] || null;
      i += 1;
      continue;
    }

    if (current === '--summary') {
      args.summary = argv[i + 1] || '';
      i += 1;
      continue;
    }

    if (current === '--help' || current === '-h') {
      usage();
      process.exit(0);
    }

    throw new Error(`Unknown argument: ${current}`);
  }

  if (!args.bump) {
    throw new Error('Missing required --bump argument.');
  }

  return args;
}

function runGitCommand(command) {
  return execSync(command, {
    cwd: ROOT,
    stdio: ['ignore', 'pipe', 'pipe'],
    encoding: 'utf8',
  }).trim();
}

function getChangedFiles() {
  const staged = runGitCommand('git diff --cached --name-only');

  if (staged) {
    return staged.split('\n').filter(Boolean);
  }

  const workingTree = runGitCommand('git diff --name-only HEAD');

  if (workingTree) {
    return workingTree.split('\n').filter(Boolean);
  }

  return [];
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function ensureChangelogExists() {
  if (!fs.existsSync(CHANGELOG_FILE)) {
    fs.writeFileSync(CHANGELOG_FILE, CHANGELOG_HEADER, 'utf8');
    return;
  }

  const current = fs.readFileSync(CHANGELOG_FILE, 'utf8');

  if (current.includes(CHANGELOG_ENTRIES_MARKER)) {
    return;
  }

  const firstEntryIndex = current.indexOf('\n## [');
  const existingEntries = firstEntryIndex >= 0 ? current.slice(firstEntryIndex + 1).trim() : '';
  const normalized = `${CHANGELOG_HEADER}${existingEntries ? `${existingEntries}\n` : ''}`;

  fs.writeFileSync(CHANGELOG_FILE, normalized, 'utf8');
}

function prependChangelogEntry(entry) {
  ensureChangelogExists();

  const current = fs.readFileSync(CHANGELOG_FILE, 'utf8');

  const markerIndex = current.indexOf(CHANGELOG_ENTRIES_MARKER);
  if (markerIndex === -1) {
    throw new Error('CHANGELOG marker missing after initialization.');
  }

  const insertionPoint = markerIndex + CHANGELOG_ENTRIES_MARKER.length;
  const head = current.slice(0, insertionPoint);
  const body = current.slice(insertionPoint).trimStart();
  const nextContent = `${head}\n\n${entry}${body}`;

  fs.writeFileSync(CHANGELOG_FILE, nextContent, 'utf8');
}

function ensureVersionNotAlreadyLogged(version) {
  if (!fs.existsSync(CHANGELOG_FILE)) {
    return;
  }

  const content = fs.readFileSync(CHANGELOG_FILE, 'utf8');

  if (content.includes(`## [${version}]`)) {
    throw new Error(`CHANGELOG already contains an entry for version ${version}.`);
  }
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const changedFiles = getChangedFiles();
  const docsCheck = isDocumentationUpdateRequired(changedFiles);

  if (docsCheck.requiresDocumentationUpdate) {
    console.error('Documentation update required before release bump.');
    console.error('Impactful non-doc changes were detected without README/DOCUMENTATION/docs updates.');
    console.error('Changed files:');
    for (const file of changedFiles) {
      console.error(`- ${file}`);
    }
    process.exit(1);
  }

  const versionData = readJson(VERSION_FILE);
  const nextVersion = bumpVersion(versionData.version, args.bump);
  const timestamp = new Date().toISOString();

  ensureVersionNotAlreadyLogged(nextVersion);

  versionData.version = nextVersion;
  versionData.last_update = timestamp;

  writeJson(VERSION_FILE, versionData);

  const entry = createKeepAChangelogEntry({
    version: nextVersion,
    bump: args.bump,
    summary: args.summary,
    files: changedFiles,
    docsTouched: docsCheck.docsTouched,
    timestamp,
  });

  prependChangelogEntry(entry);

  console.log(`Updated ${path.relative(ROOT, VERSION_FILE)} to ${nextVersion}`);
  console.log(`Updated ${path.relative(ROOT, CHANGELOG_FILE)} with a new release entry`);
  console.log('Next step: review both files, then stage and commit.');
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
