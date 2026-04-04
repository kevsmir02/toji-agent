const assert = require('assert');

const {
  bumpVersion,
  isDocumentationUpdateRequired,
  createKeepAChangelogEntry,
} = require('./release-utils');

function runTests() {
  assert.strictEqual(bumpVersion('2.0.0', 'patch'), '2.0.1');
  assert.strictEqual(bumpVersion('2.0.0', 'minor'), '2.1.0');
  assert.strictEqual(bumpVersion('2.0.0', 'major'), '3.0.0');

  const docsRequiredWithoutDocsTouch = isDocumentationUpdateRequired([
    'scripts/sync-governance.js',
    '.github/skills/security/SKILL.md',
  ]);

  assert.deepStrictEqual(docsRequiredWithoutDocsTouch, {
    docsTouched: false,
    impactfulChangesDetected: true,
    requiresDocumentationUpdate: true,
  });

  const docsRequiredWithDocsTouch = isDocumentationUpdateRequired([
    'scripts/sync-governance.js',
    'README.md',
  ]);

  assert.deepStrictEqual(docsRequiredWithDocsTouch, {
    docsTouched: true,
    impactfulChangesDetected: true,
    requiresDocumentationUpdate: false,
  });

  const docsOnlyChange = isDocumentationUpdateRequired([
    'docs/maintainer/AI_SCALING_GUIDE.md',
  ]);

  assert.deepStrictEqual(docsOnlyChange, {
    docsTouched: true,
    impactfulChangesDetected: false,
    requiresDocumentationUpdate: false,
  });

  const changelogEntry = createKeepAChangelogEntry({
    version: '2.2.0',
    bump: 'minor',
    summary: 'Introduce release discipline automation',
    files: ['README.md', 'scripts/release/prepare-release.js'],
    docsTouched: true,
    timestamp: '2026-04-05T01:23:45.000Z',
  });

  assert.ok(changelogEntry.includes('## [2.2.0] - 2026-04-05'));
  assert.ok(changelogEntry.includes('### Added'));
  assert.ok(changelogEntry.includes('### Changed'));
  assert.ok(changelogEntry.includes('### Fixed'));
  assert.ok(changelogEntry.includes('### Documentation'));
  assert.ok(changelogEntry.includes('- Introduce release discipline automation'));
  assert.ok(changelogEntry.includes('- README.md'));

  console.log('release-utils tests passed');
}

runTests();
