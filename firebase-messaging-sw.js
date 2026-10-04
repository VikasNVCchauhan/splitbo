// Firebase Messaging Service Worker for Splitbo web push notifications.
// This file must live at the root of the web directory so the browser
// can register it at /firebase-messaging-sw.js

importScripts("https://www.gstatic.com/firebasejs/10.14.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDLWgzUy_UYUcyg0Rp5RBO-lxQMmpM10WU",
  authDomain: "splitbo.firebaseapp.com",
  projectId: "splitbo",
  storageBucket: "splitbo.firebasestorage.app",
  messagingSenderId: "715213443351",
  appId: "1:715213443351:web:914a3fef97f02c14382752",
});

const messaging = firebase.messaging();

// Handle background messages (app not in foreground)
messaging.onBackgroundMessage((payload) => {
  const { title, body, icon } = payload.notification ?? {};
  self.registration.showNotification(title ?? "Splitbo", {
    body: body ?? "",
    icon: icon ?? "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data: payload.data,
  });
});

// Open/focus app when notification is clicked
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((cs) => {
      if (cs.length > 0) {
        cs[0].focus();
      } else {
        clients.openWindow("/splitbo/");
      }
    })
  );
});
