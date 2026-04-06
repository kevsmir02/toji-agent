const assert = require('assert');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..', '..');

function read(relPath) {
  return fs.readFileSync(path.join(repoRoot, relPath), 'utf8');
}

function mustContain(content, needle, message) {
  assert.ok(content.includes(needle), message + ` (missing: ${needle})`);
}

function runTests() {
  const linuxInstall = read('scripts/linux/install.sh');
  const linuxUpdate = read('scripts/linux/update.sh');
  const linuxCheck = read('scripts/linux/check.sh');
  const linuxUninstall = read('scripts/linux/uninstall.sh');

  const winInstall = read('scripts/windows/windows_install.ps1');
  const winUpdate = read('scripts/windows/windows_update.ps1');
  const winCheck = read('scripts/windows/windows_check.ps1');
  const winUninstall = read('scripts/windows/windows_uninstall.ps1');

  const readme = read('README.md');
  const docs = read('DOCUMENTATION.md');
  const ci = read('.github/workflows/ci.yml');

  mustContain(linuxInstall, '--copilot-cli', 'install.sh should expose --copilot-cli flag');
  mustContain(linuxInstall, '--all', 'install.sh should expose --all flag');

  mustContain(linuxUpdate, '--copilot-cli', 'update.sh should expose --copilot-cli flag');
  mustContain(linuxUpdate, '--all', 'update.sh should expose --all flag');
  mustContain(linuxUpdate, 'copilot-cli', 'update.sh should support copilot-cli mode case');

  mustContain(linuxCheck, '--copilot-cli', 'check.sh should expose --copilot-cli flag');
  mustContain(linuxCheck, '--all', 'check.sh should expose --all flag');

  mustContain(linuxUninstall, '--copilot-cli', 'uninstall.sh should expose --copilot-cli flag');
  mustContain(linuxUninstall, '--all', 'uninstall.sh should expose --all flag');

  mustContain(winInstall, '-CopilotCli', 'windows_install.ps1 should expose -CopilotCli');
  mustContain(winInstall, '-All', 'windows_install.ps1 should expose -All');
  mustContain(winUpdate, '-CopilotCli', 'windows_update.ps1 should expose -CopilotCli');
  mustContain(winUpdate, '-All', 'windows_update.ps1 should expose -All');
  mustContain(winCheck, '-CopilotCli', 'windows_check.ps1 should expose -CopilotCli');
  mustContain(winCheck, '-All', 'windows_check.ps1 should expose -All');
  mustContain(winUninstall, '-CopilotCli', 'windows_uninstall.ps1 should expose -CopilotCli');
  mustContain(winUninstall, '-All', 'windows_uninstall.ps1 should expose -All');

  mustContain(readme, '--copilot-cli', 'README should document --copilot-cli mode');
  mustContain(readme, '--all', 'README should document --all mode');

  mustContain(docs, '--copilot-cli', 'DOCUMENTATION should document --copilot-cli mode');
  mustContain(docs, '--all', 'DOCUMENTATION should document --all mode');

  mustContain(ci, '--copilot-cli', 'CI should run a copilot-cli dry-run check');

  console.log('copilot-cli mode support tests passed');
}

runTests();
