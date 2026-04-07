const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.resolve(__dirname, '..');
const GOVERNANCE_SOURCE = path.join(ROOT_DIR, 'docs', 'ai', 'governance-core.md');

const TARGETS = [
  path.join(ROOT_DIR, '.github', 'copilot-instructions.md'),
  path.join(ROOT_DIR, '.github', 'copilot-instructions.template.md'),
  path.join(ROOT_DIR, '.github', 'agents', 'toji.agent.md'),
  path.join(ROOT_DIR, '.agent', 'agents', 'toji.agent.md')
];

function syncGovernance() {
  if (!fs.existsSync(GOVERNANCE_SOURCE)) {
    console.error(`Error: Source file not found: ${GOVERNANCE_SOURCE}`);
    process.exit(1);
  }

  const governanceContent = fs.readFileSync(GOVERNANCE_SOURCE, 'utf8').trim();
  const startMarker = '<!-- toji-governance:start -->';
  const endMarker = '<!-- toji-governance:end -->';
  const replacementText = `${startMarker}\n${governanceContent}\n${endMarker}`;

  let errorCount = 0;

  for (const target of TARGETS) {
    if (!fs.existsSync(target)) {
      console.warn(`Warning: Target file not found: ${target}`);
      continue;
    }

    const content = fs.readFileSync(target, 'utf8');
    
    // Regex matches the start marker, any content (including newlines) non-greedily, and the end marker
    const regex = new RegExp(`${startMarker}[\\s\\S]*?${endMarker}`, 'g');
    
    if (!regex.test(content)) {
      console.warn(`Warning: Markers not found in target file: ${target}`);
      continue;
    }

    const newContent = content.replace(regex, replacementText);
    
    if (content !== newContent) {
      fs.writeFileSync(target, newContent, 'utf8');
      console.log(`Updated: ${path.relative(ROOT_DIR, target)}`);
    } else {
      console.log(`Unchanged: ${path.relative(ROOT_DIR, target)}`);
    }
  }

  if (errorCount > 0) {
    process.exit(1);
  }
}

syncGovernance();
