/**
 * Offscreen document — the bridge for Firebase popup auth in MV3.
 *
 * The service worker cannot open a popup window. This offscreen document
 * hosts an invisible iframe pointing at the Firebase-hosted auth page
 * (extension-auth.html). When the service worker forwards a sign-in request,
 * we relay it to the iframe via postMessage; the iframe runs signInWithPopup
 * and posts back the OAuth credential, which we hand back to the service worker.
 */

// The Firebase-hosted page that runs signInWithPopup.
// firebaseapp.com is an auto-authorized Firebase Auth domain.
const HOSTED_URL = "https://notelayer-c7bba.firebaseapp.com/extension-auth.html";
const HOSTED_ORIGIN = new URL(HOSTED_URL).origin;

const iframe = document.createElement("iframe");
iframe.src = HOSTED_URL;
iframe.style.display = "none";
document.documentElement.appendChild(iframe);

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message?.target !== "offscreen-auth") return false;

  function onResult(event: MessageEvent) {
    if (event.origin !== HOSTED_ORIGIN) return;
    if (event.data?.target !== "notelayer-auth-result") return;
    window.removeEventListener("message", onResult);
    sendResponse(event.data);
  }
  window.addEventListener("message", onResult);

  iframe.contentWindow?.postMessage(
    { target: "notelayer-auth", provider: message.provider },
    HOSTED_ORIGIN,
  );

  return true; // keep the message channel open for the async sendResponse
});
