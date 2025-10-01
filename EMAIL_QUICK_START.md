# 🚀 Quick Start: Real Email Verification

## 📋 Setup in 3 Steps (2 minutes)

### 1️⃣ Get Resend API Key

Visit: https://resend.com
- Sign up (free, no credit card)
- Click "API Keys" → "Create API Key"
- Copy the key (starts with `re_`)

### 2️⃣ Add to .env File

Open `.env` and add:

```bash
RESEND_API_KEY=re_your_actual_key_here
EMAIL_FROM=onboarding@resend.dev
```

### 3️⃣ Test It!

```bash
flutter run
```

Enter your **real email** → Get code via email! 📧

---

## ✅ What You Get

- ✅ Professional HTML emails
- ✅ 6-digit verification codes
- ✅ 100 emails/day (free)
- ✅ Automatic expiration handling
- ✅ No console needed!

---

## 📧 Example Email

**Subject:** Verify your email - Mental Health App

```
┌────────────────────────────────┐
│   Verify Your Email            │
│                                 │
│   Use this code:               │
│                                 │
│   ┌─────────────────────┐      │
│   │   1 2 3 4 5 6       │      │
│   └─────────────────────┘      │
│                                 │
│   Expires in 10 minutes        │
└────────────────────────────────┘
```

---

## 🐛 Troubleshooting

**No email?**
- Check spam folder
- Verify API key in `.env`
- Restart app after changing `.env`

**Still shows code in console?**
- Normal! It's a fallback
- If API key is correct, email is also sent

---

## 📚 Full Documentation

- **Setup Guide**: `EMAIL_SETUP_GUIDE.md`
- **Email Service**: `lib/services/email_service.dart`
- **Templates**: Beautiful HTML included!

---

**Free tier: 100 emails/day, 3,000/month** 🎉

Perfect for development and small apps!
