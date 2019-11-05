// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

// add button clickListener
document.getElementById('nativeWindowRender').addEventListener('click', function () {
    console.log("renderer.js >> nativeWindowRender");
    document.renderaddon.openNativeWindow();
});

document.getElementById('nativeWindowMain').addEventListener('click', function () {
    console.log("renderer.js >> nativeWindowMain");
    document.openNativeWindowInMain();    
});

// show current time to ensure render process is not blocked
document.getElementById("time").innerHTML = (new Date()).toLocaleTimeString();
setInterval(() => document.getElementById("time").innerHTML = (new Date()).toLocaleTimeString(), 1000);