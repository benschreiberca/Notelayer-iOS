// MV3 service worker — handles context menu setup and background events.

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: "save-to-notelayer",
    title: "Save to Notelayer",
    contexts: ["selection"],
  });
});

// When a context menu item is clicked, store the selection
// so the popup can pre-fill it when opened.
chrome.contextMenus.onClicked.addListener((info) => {
  if (info.menuItemId === "save-to-notelayer" && info.selectionText) {
    chrome.storage.local.set({
      pendingCapture: info.selectionText.trim().slice(0, 200),
    });
    // Open the popup so the user can review and save
    chrome.action.openPopup().catch(() => {
      // openPopup may not be available in all contexts — ignore
    });
  }
});
