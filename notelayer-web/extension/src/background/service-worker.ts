import { auth, saveTask, saveNote } from "@notelayer/shared";
import { onAuthStateChanged, type User } from "firebase/auth";

let currentUser: User | null = null;

onAuthStateChanged(auth, (user) => {
  currentUser = user;
});

/* ── Firebase popup auth via offscreen document ──
 * The side panel asks the service worker to sign in; the SW spins up an
 * offscreen document (which hosts the Firebase auth iframe), relays the
 * request, and returns the resulting OAuth credential to the side panel.
 */
const OFFSCREEN_PATH = "offscreen.html";

async function hasOffscreenDocument(): Promise<boolean> {
  // @ts-expect-error - getContexts is available in recent Chrome
  if (chrome.runtime.getContexts) {
    // @ts-expect-error - OFFSCREEN_DOCUMENT context type
    const contexts = await chrome.runtime.getContexts({ contextTypes: ["OFFSCREEN_DOCUMENT"] });
    return contexts.length > 0;
  }
  return false;
}

async function ensureOffscreenDocument(): Promise<void> {
  if (await hasOffscreenDocument()) return;
  await chrome.offscreen.createDocument({
    url: OFFSCREEN_PATH,
    reasons: [chrome.offscreen.Reason.DOM_SCRAPING],
    justification: "Firebase Authentication popup (Google / Apple sign-in).",
  });
}

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message?.action !== "firebase-auth") return false;
  (async () => {
    try {
      await ensureOffscreenDocument();
      const result = await chrome.runtime.sendMessage({
        target: "offscreen-auth",
        provider: message.provider,
      });
      sendResponse(result);
    } catch (err: any) {
      sendResponse({ ok: false, error: err?.message || String(err) });
    }
  })();
  return true; // async response
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
