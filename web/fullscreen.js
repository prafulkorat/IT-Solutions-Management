function toggleFullScreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
    } else {
        document.exitFullscreen();
    }
}

document.addEventListener("fullscreenchange", () => {
    let isFullscreen = document.fullscreenElement ? "true" : "false";
    window.parent.postMessage({ type: "fullscreen_changed", isFullscreen: isFullscreen }, "*");
});

window.toggleFullScreen = toggleFullScreen;
