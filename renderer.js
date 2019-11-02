// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

document.getElementById('nativeWindowRender').addEventListener('click', function () {
    console.log("renderer.js >> nativeWindowRender");
    document.renderaddon.openNativeWindow();
});

document.getElementById('nativeWindowMain').addEventListener('click', function () {
    console.log("renderer.js >> nativeWindowMain");
    document.openNativeWindowInMain();    
});
