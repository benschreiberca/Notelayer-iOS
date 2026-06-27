// Service worker: opens the side panel when the toolbar icon is clicked.
// Auth and Firestore work happens in the side panel page itself.

// Open the side panel on action click (Chrome 116+).
chrome.sidePanel
  .setPanelBehavior({ openPanelOnActionClick: true })
  .catch((err) => console.error("[Notelayer] setPanelBehavior failed:", err));

// Optional keyboard/programmatic open fallback.
chrome.action.onClicked.addListener(async (tab) => {
  try {
    await chrome.sidePanel.open({ windowId: tab.windowId });
  } catch (err) {
    console.error("[Notelayer] sidePanel.open failed:", err);
  }
});
