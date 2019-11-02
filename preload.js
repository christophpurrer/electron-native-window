// All of the Node.js APIs are available in the preload process.
// It has the same sandbox as a Chrome extension.
const { remote } = require('electron');
const openNativeWindowInMain = remote.require('./main').openNativeWindowInMain;
window.document.openNativeWindowInMain = openNativeWindowInMain;

const renderaddon = require('./utils').requireAddon('addon');
window.document.renderaddon = renderaddon;