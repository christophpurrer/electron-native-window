const fs = require('fs');
const path = require('path');
const plist = require('plist');

async function patchRendererProcessInfoPlist() {
  if (process.platform === 'darwin') {
    const ELECTRON_RENDERER_BINARY_PATH =
      'node_modules/electron/dist/Electron.app/Contents/Frameworks/Electron Helper (Renderer).app';
    const plistPath = path.join(
      __dirname,
      ELECTRON_RENDERER_BINARY_PATH,
      'Contents/Info.plist',
    );

    const properties = plist.parse(fs.readFileSync(plistPath, 'utf8'));
    if (!properties['NSHighResolutionCapable']) {
      properties['NSHighResolutionCapable'] = true;
      fs.writeFileSync(plistPath, plist.build(properties));
    }
  }
}

if (require.main === module) {
  patchRendererProcessInfoPlist().catch(error => {
    console.error(error);
    process.exit(1);
  });
}
