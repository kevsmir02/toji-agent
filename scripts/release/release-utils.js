const IMPACTFUL_CHANGE_PATTERNS = [
  /^scripts\//,
  /^\.github\/(skills|prompts|agents|instructions|workflows)\//,
  /^\.github\/copilot-instructions(\.template)?\.md$/,
  /^\.github\/toji-version\.json$/,
  /^\.agent\/(agents|workflows)\//,
  /^AGENTS\.md$/,
  /^docs\/ai\//,
];

function parseSemVer(version) {
  const match = /^(\d+)\.(\d+)\.(\d+)$/.exec(version);

  if (!match) {
    throw new Error(`Invalid semantic version: ${version}`);
  }

  return {
    major: Number(match[1]),
    minor: Number(match[2]),
    patch: Number(match[3]),
  };
}

function bumpVersion(currentVersion, bumpType) {
  const parsed = parseSemVer(currentVersion);

  if (bumpType === 'major') {
    return `${parsed.major + 1}.0.0`;
  }

  if (bumpType === 'minor') {
    return `${parsed.major}.${parsed.minor + 1}.0`;
  }

  if (bumpType === 'patch') {
    return `${parsed.major}.${parsed.minor}.${parsed.patch + 1}`;
  }

  throw new Error(`Invalid bump type: ${bumpType}. Expected major, minor, or patch.`);
}

function isDocumentationPath(filePath) {
  return (
    filePath === 'README.md' ||
    filePath === 'DOCUMENTATION.md' ||
    filePath.startsWith('docs/')
  );
}

function isDocumentationUpdateRequired(changedFiles) {
  const normalizedFiles = Array.from(
    new Set(
      changedFiles
        .map((entry) => entry.trim())
        .filter(Boolean)
    )
  );

  const docsTouched = normalizedFiles.some((filePath) => isDocumentationPath(filePath));
  const impactfulChangesDetected = normalizedFiles.some((filePath) => {
    if (isDocumentationPath(filePath)) {
      return false;
    }

    return IMPACTFUL_CHANGE_PATTERNS.some((pattern) => pattern.test(filePath));
  });

  return {
    docsTouched,
    impactfulChangesDetected,
    requiresDocumentationUpdate: impactfulChangesDetected && !docsTouched,
  };
}

function toDateOnly(isoTimestamp) {
  return isoTimestamp.slice(0, 10);
}

function createKeepAChangelogEntry({ version, bump, summary, files, docsTouched, timestamp }) {
  const renderedSummary = summary || 'Maintainer update';
  const renderedFiles = files.length > 0 ? files : ['(No file changes detected)'];

  return [
    `## [${version}] - ${toDateOnly(timestamp)}`,
    '',
    '### Added',
    bump === 'major' || bump === 'minor'
      ? `- Release bump type: ${bump}`
      : '- None',
    '',
    '### Changed',
    `- ${renderedSummary}`,
    '- Auto-detected changed files:',
    ...renderedFiles.map((file) => `- ${file}`),
    '',
    '### Fixed',
    bump === 'patch'
      ? '- Release bump type: patch'
      : '- None',
    '',
    '### Documentation',
    docsTouched
      ? '- README/DOCUMENTATION/docs updates were included in this release.'
      : '- No documentation files changed in this release.',
    '',
  ].join('\n');
}

module.exports = {
  bumpVersion,
  isDocumentationUpdateRequired,
  createKeepAChangelogEntry,
};
