# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- None

### Changed
- None

### Fixed
- None

<!-- changelog-entries -->

## [2.1.1] - 2026-04-04

### Added
- None

### Changed
- Maintainer pre-commit automation
- Auto-detected changed files:
- .github/lessons-learned.md
- scripts/linux/update.sh
- scripts/release/precommit-release-automation.test.js
- scripts/release/prepare-release.js

### Fixed
- Release bump type: patch

### Documentation
- No documentation files changed in this release.
## [2.1.0] - 2026-04-04

### Added
- Release bump type: minor

### Changed
- Add maintainer release automation for docs guard, semver bump, and changelog generation
- Auto-detected changed files:
- DOCUMENTATION.md
- README.md
- docs/maintainer/AI_SCALING_GUIDE.md

### Fixed
- None

### Documentation
- README/DOCUMENTATION/docs updates were included in this release.

## [2.0.0] - 2026-04-04

### Added
- Release bump type: major

### Changed
- Backfilled history starting from `f481227e4fea4cba4c215df830c6ba6bb55df892` through `5f0287703ba266730f00ab4621fb13318735e04e`.
- Consolidated governance surfaces, removed Antigravity skill mirrors, and strengthened maintainer governance contracts.
- Backfilled commits:
- `f481227` refactor: consolidate governance surfaces and remove Antigravity skill mirrors
- `e715b1b` docs: add AI scaling and maintainer guide
- `8a5a546` docs: refine maintainer vs consumer context in AI scaling guide
- `d441cc1` docs(maintainer): add source-vs-consumer contract and scaling checklist
- `5f02877` chore: enforce canonical-derived artifact hierarchy
- Key changed surfaces:
- `.agent/workflows/*` and `.agent/agents/toji.agent.md`
- `.github/copilot-instructions.md` and `.github/copilot-instructions.template.md`
- `docs/maintainer/AI_SCALING_GUIDE.md`
- `README.md`, `DOCUMENTATION.md`, and governance sync scripts

### Fixed
- None

### Documentation
- README and maintainer documentation were updated as part of this release history.
