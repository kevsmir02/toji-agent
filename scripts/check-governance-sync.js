const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const GOVERNANCE_SOURCE = path.join(ROOT_DIR, 'docs', 'ai', 'governance-core.md');
const START_MARKER = '<!-- toji-governance:start -->';
const END_MARKER = '<!-- toji-governance:end -->';

const TARGETS = [
  path.join(ROOT_DIR, '.github', 'copilot-instructions.md'),
  path.join(ROOT_DIR, '.github', 'copilot-instructions.template.md'),
  path.join(ROOT_DIR, '.github', 'agents', 'toji.agent.md'),
  path.join(ROOT_DIR, '.agent', 'agents', 'toji.agent.md')
];

function extractGovernanceBlock(content) {
  const start = content.indexOf(START_MARKER);
  const end = content.indexOf(END_MARKER);

  if (start === -1 || end === -1 || end < start) {
    return null;
  }

  const innerStart = start + START_MARKER.length;
  const inner = content.slice(innerStart, end);
  return inner.trim();
}

function firstDifferentLines(source, target, limit = 3) {
  const sourceLines = source.split('\n');
  const targetLines = target.split('\n');
  const maxLen = Math.max(sourceLines.length, targetLines.length);
  const diffs = [];

  for (let i = 0; i < maxLen; i++) {
    if ((sourceLines[i] || '') !== (targetLines[i] || '')) {
      diffs.push({
        line: i + 1,
        source: sourceLines[i] || '',
        target: targetLines[i] || ''
      });
      if (diffs.length >= limit) {
        break;
      }
    }
  }

  return diffs;
}

function checkGovernanceSync() {
  if (!fs.existsSync(GOVERNANCE_SOURCE)) {
    console.error(`Source governance file not found: ${GOVERNANCE_SOURCE}`);
    process.exit(1);
  }

  const source = fs.readFileSync(GOVERNANCE_SOURCE, 'utf8').trim();
  let hasMismatch = false;

  for (const targetPath of TARGETS) {
    if (!fs.existsSync(targetPath)) {
      console.error(`❌ Missing target: ${path.relative(ROOT_DIR, targetPath)}`);
      hasMismatch = true;
      continue;
    }

    const content = fs.readFileSync(targetPath, 'utf8');
    const extracted = extractGovernanceBlock(content);

    if (extracted === null) {
      console.error(`❌ Missing markers: ${path.relative(ROOT_DIR, targetPath)}`);
      hasMismatch = true;
      continue;
    }

    if (extracted === source) {
      console.log(`✅ Synced: ${path.relative(ROOT_DIR, targetPath)}`);
      continue;
    }

    hasMismatch = true;
    console.error(`❌ Drift detected: ${path.relative(ROOT_DIR, targetPath)}`);
    const diffs = firstDifferentLines(source, extracted, 3);
    for (const diff of diffs) {
      console.error(`   Line ${diff.line}`);
      console.error(`   expected: ${diff.source}`);
      console.error(`   actual  : ${diff.target}`);
    }
  }

  process.exit(hasMismatch ? 1 : 0);
}

checkGovernanceSync();
