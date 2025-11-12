// /web/firebase-messaging-sw.js

// Firebase SDK のスクリプトをインポートします
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

// あなたの firebase_options.dart にある Web 用の Firebase 設定
const firebaseConfig = {
    apiKey: "AIzaSyBCCxQ0AYTHy6A6DrfW7ylYxjGW6AZA1OQ",
    authDomain: "whatsappclone-5ad8f.firebaseapp.com",
    projectId: "whatsappclone-5ad8f",
    storageBucket: "whatsappclone-5ad8f.firebasestorage.app",
    messagingSenderId: "1049878222012",
    appId: "1:1049878222012:web:54584a8098728e70acecb9",
    measurementId: "G-EQ99QMVB2Y"
};

// Firebase を初期化
firebase.initializeApp(firebaseConfig);

// メッセージングインスタンスを取得
const messaging = firebase.messaging();