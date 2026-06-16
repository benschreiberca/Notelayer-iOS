import { auth, saveTask, saveNote } from "@notelayer/shared";
import { onAuthStateChanged, type User } from "firebase/auth";

let currentUser: User | null = null;

onAuthStateChanged(auth, (user) => {
  currentUser = user;
});

chrome.runtime.onInstalled.addListener(() => {
  // Open side panel by default on action click
  chrome.sidePanel.setPanelBehavior({ openPanelOnActionClick: true }).catch(console.error);

  chrome.contextMenus.create({
    id: "notelayer-save-task",
    title: "Save to Notelayer as Task",
    contexts: ["selection", "page"],
  });
  chrome.contextMenus.create({
    id: "notelayer-save-note",
    title: "Save to Notelayer as Note",
    contexts: ["selection", "page"],
  });
});

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (!currentUser) {
    // Open side panel so user can sign in
    if (tab?.id) {
      chrome.sidePanel.open({ tabId: tab.id }).catch(console.error);
    }
    return;
  }
  const text = info.selectionText || tab?.title || "";
  const url = tab?.url || "";

  if (info.menuItemId === "notelayer-save-task") {
    await saveTask(currentUser.uid, {
      title: text,
      priority: null,
      categories: [],
      isCompleted: false,
      dueDate: null,
      taskNotes: url ? `Source: ${url}` : null,
      parentTaskId: null,
      orderIndex: Date.now(),
      createdFrom: "chrome-extension-context-menu",
    });
    // Open panel to show the saved task
    if (tab?.id) {
      chrome.sidePanel.open({ tabId: tab.id }).catch(console.error);
    }
  }

  if (info.menuItemId === "notelayer-save-note") {
    await saveNote(currentUser.uid, {
      text: url ? `${text}\n\nSource: ${url}` : text,
      isPinned: false,
      createdFrom: "chrome-extension-context-menu",
    });
    if (tab?.id) {
      chrome.sidePanel.open({ tabId: tab.id }).catch(console.error);
    }
  }
});
