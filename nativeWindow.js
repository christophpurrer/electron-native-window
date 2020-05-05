const { BrowserWindow } = require('electron');
const addon = require('./utils').requireAddon('addon');

class NativeWindow extends BrowserWindow {
  constructor(options) {
    const o = { ...options };
    o.frame = true;
    super(o);
    if (!options.frame === undefined) options.frame = true
    addon.makeNativeWindow(this.getNativeWindowHandle(), options.frame);
  }
}

module.exports = {
  NativeWindow
};
