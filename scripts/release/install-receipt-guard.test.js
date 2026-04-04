const assert = require('assert');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..', '..');
const installScript = fs.readFileSync(path.join(repoRoot, 'scripts/linux/install.sh'), 'utf8');
const checkScript = fs.readFileSync(path.join(repoRoot, 'scripts/linux/check.sh'), 'utf8');
const updateScript = fs.readFileSync(path.join(repoRoot, 'scripts/linux/update.sh'), 'utf8');

function runTests() {
  assert.ok(
    !installScript.includes('install-receipt.json'),
    'install.sh must not generate install-receipt.json'
  );

  assert.ok(
    !checkScript.includes('install-receipt.json'),
    'check.sh must not reference install-receipt.json'
  );

  assert.ok(
    updateScript.includes('Blocked path: .toji_tmp/'),
    'pre-commit hook template in update.sh must block .toji_tmp staged paths'
  );

  console.log('install-receipt guard tests passed');
}

runTests();
