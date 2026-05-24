// Notelayer Chrome Extension — Service Worker
// Handles background tasks and extension lifecycle

chrome.runtime.onInstalled.addListener(() => {
  console.log('Notelayer extension installed')
})
