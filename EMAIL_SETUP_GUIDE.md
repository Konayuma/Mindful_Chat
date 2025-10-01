# 📧 Email Integration Setup Guide - Resend

## ✅ Step-by-Step Setup (5 minutes)

### Step 1: Sign Up for Resend

1. Go to: https://resend.com
2. Click **"Start Building"** or **"Sign Up"**
3. Sign up with:
   - GitHub (recommended - instant)
   - Google
   - Or email

### Step 2: Get Your API Key

1. After signing in, you'll see the dashboard
2. Click **"API Keys"** in the left sidebar
3. Click **"Create API Key"**
4. Give it a name: `Mental Health App - Dev`
5. Select permissions: **"Sending access"**
6. Click **"Create"**
7. **Copy the API key** (starts with `re_`)
   - ⚠️ Save it now! You won't see it again

### Step 3: Add API Key to .env File

1. Open your `.env` file in VS Code
2. Add these lines:

```bash
# Email Service Configuration
RESEND_API_KEY=re_your_actual_api_key_here
EMAIL_FROM=onboarding@resend.dev
```

Replace `re_your_actual_api_key_here` with the API key you just copied.

**Example `.env` file:**
```bash
SUPABASE_URL=https://wlpuqichfpxrwchzrdzz.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
RESEND_API_KEY=re_abc123xyz789...
EMAIL_FROM=onboarding@resend.dev
```

### Step 4: Test It!

```bash
flutter run
```

1. Enter your **real email address** on signup
2. Click "Get Started"
3. **Check your email inbox!** 📬
4. You should receive a beautiful email with a 6-digit code
5. Enter the code in the app
6. Verify and proceed!

---

## 🎯 What You Get

### Free Tier Benefits:
- ✅ **100 emails per day**
- ✅ **3,000 emails per month**
- ✅ Beautiful HTML emails
- ✅ No credit card required
- ✅ Perfect for development & testing

### Email Features:
- ✅ Professional HTML templates
- ✅ 6-digit verification codes
- ✅ 10-minute expiration notice
- ✅ Responsive design (looks good on mobile)
- ✅ Support contact info

---

## 📧 Email Templates

### 1. Verification Code Email

Sent when user signs up:

**Subject:** Verify your email - Mental Health App

**Content:**
- Clean, professional design
- Large, easy-to-read 6-digit code
- 10-minute expiration notice
- Support contact information

**Preview:**
```
┌─────────────────────────────────┐
│     Verify Your Email           │
│                                  │
│  Thank you for signing up!      │
│                                  │
│  ┌───────────────────────────┐  │
│  │      1 2 3 4 5 6          │  │
│  └───────────────────────────┘  │
│                                  │
│  Expires in 10 minutes          │
└─────────────────────────────────┘
```

### 2. Welcome Email (Optional)

Sent after successful verification:

**Subject:** Welcome to Mental Health App! 🌟

### 3. Password Reset Email (Future)

For password reset functionality.

---

## 🔧 Configuration Options

### Using Your Own Domain (Optional)

To send from your own domain (e.g., `verify@yourdomain.com`):

1. **Add Domain in Resend:**
   - Go to Resend Dashboard → **Domains**
   - Click **"Add Domain"**
   - Enter your domain: `yourdomain.com`
   - Follow DNS setup instructions

2. **Verify Domain:**
   - Add SPF, DKIM, DMARC records to your DNS
   - Wait for verification (usually 5-10 minutes)

3. **Update .env:**
   ```bash
   EMAIL_FROM=verify@yourdomain.com
   ```

### Testing Address (Default)

Resend provides a testing address that works without domain setup:
```bash
EMAIL_FROM=onboarding@resend.dev
```

**Use this for development!** No DNS setup needed.

---

## 🧪 Testing

### Test Checklist:

- [ ] Added `RESEND_API_KEY` to `.env`
- [ ] Added `EMAIL_FROM` to `.env`
- [ ] Ran `flutter run`
- [ ] Entered **real email address** on signup
- [ ] Received email in inbox (check spam folder)
- [ ] Email has 6-digit code
- [ ] Code works in app
- [ ] Verified successfully

### Check Email Delivery:

1. **Resend Dashboard:**
   - Go to **"Emails"** tab
   - See all sent emails
   - Check delivery status
   - View email content

2. **Check Spam Folder:**
   - First email might go to spam
   - Mark as "Not Spam"
   - Future emails should reach inbox

---

## 🐛 Troubleshooting

### ❌ No Email Received

**Check:**
1. **Spam/Junk folder** - Most common issue
2. **Email address is correct** - Check for typos
3. **Resend Dashboard** - See if email was sent
4. **API Key is correct** - Check `.env` file
5. **App restarted** - Restart after changing `.env`

**Fix:**
```bash
# Restart the app after .env changes
flutter clean
flutter run
```

### ❌ "Failed to send email"

**Check Console Output:**
```
⚠️ RESEND_API_KEY not found in .env file
```

**Fix:** Add API key to `.env` file

**Check Console Output:**
```
❌ Failed to send email: 401
Response: {"error": "Invalid API key"}
```

**Fix:** API key is wrong, get new one from Resend

### ❌ API Key Not Found

**Problem:** `.env` file not loaded

**Fix:**
1. Verify `.env` file is in project root
2. Check `pubspec.yaml` has:
   ```yaml
   flutter:
     assets:
       - .env
   ```
3. Restart app

### ❌ Code Still Printed to Console

**This is normal!** The code is printed as a fallback if email fails.

**When email works:**
```
✅ Verification email sent to user@example.com
```

**When email fails:**
```
⚠️ Email sending failed, but code stored in database
🔐 Verification code for user@example.com: 123456
```

---

## 📊 Monitoring

### View Email Analytics

1. Go to **Resend Dashboard**
2. Click **"Emails"** in sidebar
3. See:
   - Total emails sent
   - Delivery rate
   - Failed emails
   - Email content preview

### Check Logs

In your app console:
```
✅ Verification email sent to user@example.com  ← Success!
❌ Failed to send email: 429                     ← Rate limit
⚠️ Email sending failed                          ← Fallback mode
```

---

## 🚀 Production Checklist

Before going live:

- [ ] Get Resend Pro plan (if needed for volume)
- [ ] Set up your own domain
- [ ] Verify domain DNS records
- [ ] Update `EMAIL_FROM` to your domain
- [ ] Test from multiple email providers (Gmail, Outlook, Yahoo)
- [ ] Set up email monitoring/alerts
- [ ] Remove console logging (optional)
- [ ] Test spam score (tools like mail-tester.com)

---

## 💰 Pricing

### Free Tier (Current):
- ✅ 100 emails/day
- ✅ 3,000 emails/month
- ✅ 1 verified domain
- ✅ Email delivery tracking
- ✅ API access

**Perfect for:**
- Development
- Testing
- Small apps (< 100 users)

### Pro Tier ($20/month):
- ✅ 50,000 emails/month
- ✅ Unlimited domains
- ✅ Priority support
- ✅ Advanced analytics

**Upgrade when:**
- You exceed 3,000 emails/month
- You need more than 100 emails/day
- You want custom domains

---

## 🔄 Alternative Email Services

If you prefer a different service:

### SendGrid
- More features
- More complex setup
- Free tier: 100 emails/day

### AWS SES
- Very cheap at scale
- Requires AWS account
- More technical setup

### Mailgun
- Good for developers
- Free tier: 5,000 emails/month
- Requires credit card

### Brevo (formerly Sendinblue)
- Free tier: 300 emails/day
- SMS capability
- Marketing features

**Resend is recommended** because:
- ✅ Simplest API
- ✅ Best developer experience
- ✅ No credit card for free tier
- ✅ Modern, clean interface

---

## 📝 Summary

### What You Did:
1. ✅ Created beautiful HTML email templates
2. ✅ Integrated Resend API
3. ✅ Configured environment variables
4. ✅ Real emails sent to users!

### What Happens Now:
```
User signs up
      ↓
6-digit code generated
      ↓
Code stored in Supabase
      ↓
📧 Email sent via Resend ← NEW!
      ↓
User receives beautiful email
      ↓
User enters code
      ↓
Verified! ✅
```

### Next Steps:
1. Get your Resend API key
2. Add to `.env` file
3. Test with your real email
4. Enjoy professional email verification!

---

## 🆘 Need Help?

- **Resend Docs**: https://resend.com/docs
- **Resend Support**: support@resend.com
- **Resend Discord**: https://resend.com/discord

---

**Ready to send real emails!** 🚀📧

Get your API key from https://resend.com and add it to your `.env` file!
