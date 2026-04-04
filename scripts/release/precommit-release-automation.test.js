const assert = require('assert');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..', '..');
const updateScript = fs.readFileSync(path.join(repoRoot, 'scripts/linux/update.sh'), 'utf8');

function runTests() {
  assert.ok(
    updateScript.includes('scripts/release/prepare-release.js'),
    'pre-commit hook template must invoke release preparation in maintainer context'
  );

  assert.ok(
    updateScript.includes('TOJI_RELEASE_BUMP'),
    'pre-commit hook template must support configurable release bump type'
  );

  assert.ok(
    updateScript.includes('git add .github/toji-version.json CHANGELOG.md'),
    'pre-commit hook template must stage release metadata files after auto-prep'
  );

  console.log('pre-commit release automation tests passed');
}

runTests();
