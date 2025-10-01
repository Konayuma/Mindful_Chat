# ✅ Supabase OTP Quick Setup Checklist

## 2-Minute Setup Guide

### Step 1: Configure Supabase Email Template (1 min)

1. Open https://wlpuqichfpxrwchzrdzz.supabase.co
2. Go to **Authentication** → **Email Templates**
3. Click **"Magic Link"** template
4. Replace content with:

```html
<h2>One-Time Login Code</h2>
<p>Please enter this code to log in:</p>
<h1>{{ .Token }}</h1>
<p>The code is valid for a short period.</p>
```

5. Click **Save**

### Step 2: Disable Email Confirmation (30 seconds)

1. Go to **Authentication** → **Providers** → **Email**
2. **Turn OFF** "Confirm email" toggle
3. Click **Save**

### Step 3: Test Your App (30 seconds)

```powershell
flutter run
```

1. Enter your email
2. Check inbox for 6-digit code
3. Enter code
4. Set password
5. Done! ✅

## What Changed?

### Before (Custom System):
- ❌ Required Resend API key
- ❌ Required custom database table
- ❌ Required external email service
- ❌ 400+ lines of custom code

### After (Supabase OTP):
- ✅ No external services needed
- ✅ No custom database tables
- ✅ No API keys to manage
- ✅ 80 lines using Supabase SDK
- ✅ Just works!™️

## Files Modified

1. **`lib/services/email_verification_service.dart`**
   - Now uses `signInWithOtp()` and `verifyOTP()`
   - Removed custom code generation and database logic

2. **`lib/screens/create_password_screen.dart`**
   - Changed from `signUpWithEmail()` to `updatePassword()`
   - User is pre-authenticated via OTP

3. **`lib/screens/email_verification_screen.dart`**
   - Minor UI updates (added emoji, reduced delay)

## Files You Can Delete (Optional)

No longer needed:

```
lib/services/email_service.dart
verification_codes_schema.sql
EMAIL_SETUP_GUIDE.md
EMAIL_QUICK_START.md
EMAIL_VERIFICATION_DOCS.md
EMAIL_VERIFICATION_UPGRADE.md
SUPABASE_EMAIL_CONFIRMATION_FIX.md
```

Keep for reference:

```
SUPABASE_OTP_SETUP.md (comprehensive guide)
MIGRATION_CUSTOM_TO_OTP.md (migration notes)
OTP_QUICK_CHECKLIST.md (this file)
```

## Testing Checklist

- [ ] Supabase email template updated
- [ ] "Confirm email" toggle disabled
- [ ] App builds without errors
- [ ] OTP email received (check spam)
- [ ] Code verification works
- [ ] Password creation successful
- [ ] Can sign in with email/password

## Common Issues

### "Not receiving email"
✅ Check spam folder  
✅ Wait 60 seconds between requests  
✅ Verify email address is correct  

### "Still getting magic link"
✅ Disable "Confirm email" in Supabase  
✅ Request new code after disabling  

### "Invalid code"
✅ Code expires in 1 hour  
✅ Each code single-use only  
✅ Check for typos (0 vs O, 1 vs l)  

## For Production

### Optional: Custom SMTP Setup

For unlimited emails and custom domain:

1. Go to **Settings** → **Project Settings** → **SMTP Settings**
2. Configure your SMTP provider (Gmail, SendGrid, AWS SES, etc.)
3. Update sender email to your domain (e.g., verify@yourdomain.com)

Free SMTP options:
- Gmail: 500 emails/day
- SendGrid: 100 emails/day  
- Mailgun: 5000 emails/month

## Documentation

📚 **Full Guide:** `SUPABASE_OTP_SETUP.md`  
🔄 **Migration Notes:** `MIGRATION_CUSTOM_TO_OTP.md`  
📖 **Supabase Docs:** https://supabase.com/docs/guides/auth/auth-otp

## Status

✅ **All code changes complete**  
✅ **No compilation errors**  
✅ **Ready to test**

---

**Next Step:** Configure Supabase email template (2 minutes) → Test sign-up flow
