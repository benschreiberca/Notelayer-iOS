/**
 * Notelayer Chrome Extension — Background Service Worker
 *
 * Phase 1: context menu registration only.
 * Phase 2: Firebase Auth persistence + Firestore operations.
 */

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'notelayer-save-note',
    title: 'Save to Notelayer as Note',
    contexts: ['selection', 'page'],
  });

  chrome.contextMenus.create({
    id: 'notelayer-save-task',
    title: 'Save to Notelayer as Task',
    contexts: ['selection', 'page'],
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  const text = info.selectionText || tab?.title || '';
  const url  = tab?.url || '';

  if (info.menuItemId === 'notelayer-save-note') {
    // TODO: call firestoreService.saveNote({ text, sourceUrl: url })
    console.log('[Notelayer] Context menu → save note:', { text, url });
  }

  if (info.menuItemId === 'notelayer-save-task') {
    // TODO: call firestoreService.saveTask({ title: text, sourceUrl: url })
    console.log('[Notelayer] Context menu → save task:', { text, url });
  }
});
