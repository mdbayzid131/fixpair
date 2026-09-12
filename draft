ব্যাকএন্ড ডেভেলপার এবং অ্যাপল অ্যাকাউন্টের মাধ্যমে **Apple APNs VoIP Push (PushKit)** ইন্টিগ্রেশন করার সম্পূর্ণ গাইড নিচে ধাপে ধাপে তুলে ধরা হলো:

---

### 🔑 ধাপ ১: Apple Developer একাউন্ট থেকে কী (Key) সংগ্রহ (১ বারের কাজ)

1. [Apple Developer Console](https://developer.apple.com/account/resources/authkeys/list) এ লগইন করুন।
2. **Certificates, Identifiers & Profiles > Keys** এ যান।
3. **(+)** বাটনে ক্লিক করে একটি নতুন Key তৈরি করুন:
   - Key Name: `Fixpair APNs Key`
   - **Apple Push Notifications service (APNs)** চেকবক্সটি টিক দিন।
4. **Continue > Register > Download** করে `.p8` ফাইলটি ডাউনলোড করে নিরাপদে সংরক্ষণ করুন (এটি আর দ্বিতীয়বার ডাউনলোড করা যায় না)।
5. নিচের ৩টি তথ্য নোট করে নিন:
   - **Key ID** (১০ ডিজিটের কোড)
   - **Team ID** (আপনার অ্যাপল একাউন্টের টিম আইডি)
   - **Bundle ID** (`com.fixpair.app`)

---

### 📱 ধাপ ২: মোবাইল অ্যাপ থেকে VoIP Token ব্যাকএন্ডে সেভ করা

iOS ডিভাইসে কলকিট চালু হওয়ার পর একটি আলাদা **VoIP Token** তৈরি হয়:
- মোবাইল অ্যাপ স্টার্টআপে `FlutterCallkitIncoming.getDevicePushTokenVoIP()` এর মাধ্যমে এই টোকেনটি পাবে।
- ব্যাকএন্ডে একটি এপিআই এন্ডপয়েন্ট থাকবে (যেমন: `POST /api/v1/user/save-device-token`):
```json
{
  "deviceToken": "...",
  "voipToken": "<IOS_VOIP_DEVICE_TOKEN>"
}
```
- ব্যাকএন্ড ইউজার টেবিলে `voipToken` ফিল্ডে এটি সংরক্ষণ করবে।

---

### 💻 ধাপ ৩: ব্যাকএন্ড কোড ইমপ্লিমেন্টেশন (Node.js Example)

ব্যাকএন্ডে (Node.js) `@parse/node-apn` লাইব্রেরি ব্যবহার করে খুব সহজেই VoIP পুশ পাঠানো যায়।

#### ১. লাইব্রেরি ইনস্টল করুন:
```bash
npm install @parse/node-apn
```

#### ২. VoIP Push পাঠানোর কোড:
```javascript
const apn = require('@parse/node-apn');

// APNs Provider কনফিগারেশন
const apnProvider = new apn.Provider({
  token: {
    key: 'path/to/AuthKey_XXXXXXXXXX.p8', // ডাউনলোড করা .p8 ফাইলের পাথ
    keyId: 'XXXXXXXXXX',                  // আপনার Key ID
    teamId: 'YYYYYYYYYY',                 // আপনার Team ID
  },
  production: true, // TestFlight/Production এর জন্য true, Development বিল্ডের জন্য false
});

/**
 * iOS ডিভাইসে VoIP Call Push পাঠানোর ফাংশন
 */
async function sendVoIPCallPush({
  voipToken,
  sessionId,
  agoraToken,
  channelName,
  bookingId,
  consultantName,
  consultantAvatar,
}) {
  const notification = new apn.Notification();

  // ⚠️ অত্যন্ত গুরুত্বপূর্ণ: VoIP এর জন্য Topic এ অবশ্যই অ্যাপের Bundle ID এর শেষে .voip থাকতে হবে
  notification.topic = 'com.fixpair.app.voip';
  
  // VoIP পুশ সবসময় High Priority (10) হতে হয়
  notification.priority = 10;
  notification.pushType = 'voip';
  notification.expiry = Math.floor(Date.now() / 1000) + 30; // ৩০ সেকেন্ড এক্সপায়ারি

  // কল ডাটা পেলোড (CallKit যা রিসিভ করবে)
  notification.payload = {
    type: 'INCOMING_CALL',
    sessionId: String(sessionId),
    token: String(agoraToken),
    channelName: String(channelName),
    bookingId: String(bookingId),
    callerName: String(consultantName || 'Consultant'),
    callerAvatar: String(consultantAvatar || ''),
    nameCaller: String(consultantName || 'Consultant'),
    handle: 'Video Consultation',
    hasVideo: true,
  };

  try {
    const result = await apnProvider.send(notification, voipToken);
    console.log('✅ [VoIP Push Sent Success]:', result.sent);
    if (result.failed && result.failed.length > 0) {
      console.error('❌ [VoIP Push Failed]:', result.failed);
    }
  } catch (error) {
    console.error('❌ [VoIP Error]:', error);
  }
}
```

---

### 🚀 এটি করার পর কী ঘটবে?
1. কনসালট্যান্ট যখন কল দেবে, ব্যাকএন্ড এই `sendVoIPCallPush` মেথড কল করবে।
2. ব্যবহারকারীর আইফোন লক থাকুক, পকেটে থাকুক বা অ্যাপ কিল করা থাকুক — **অ্যাপল সিস্টেম কোনো নোটিফিকেশন ব্যানার ছাড়াই সরাসরি WhatsApp/FaceTime এর মতো ফুল-স্ক্রিনে রিং বাজাবে (Ringtone + Accept/Decline বাটন)**।
3. ব্যবহারকারী Accept বাটনে চাপ দিলে সরাসরি কল কানেক্ট হয়ে যাবে!