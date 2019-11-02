module.exports = {
    requireAddon: function (name) {
        let addon = null;
        try {
            addon = require(`./build/Debug/${name}`);
        }
        catch (err) {
            addon = require(`./build/Release/${name}`);
        }
        return addon;
    }
}