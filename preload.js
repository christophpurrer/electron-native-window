// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
const openNativeWindowInMain = require('electron').remote.require('./main').openNativeWindowInMain;
window.document.openNativeWindowInMain = openNativeWindowInMain;

const renderaddon = require('./utils').requireAddon('addon');
if (process.platform === 'darwin') {
    renderaddon.init();
}
console.log(`render process.pid: ${process.pid}`)
window.document.renderaddon = renderaddon;