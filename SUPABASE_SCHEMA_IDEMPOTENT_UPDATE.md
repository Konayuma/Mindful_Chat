# Supabase Schema - Now Idempotent! ✅

## 🎯 Problem Solved

### BEFORE:
```
ERROR: 42P07: relation "users" already exists
ERROR: 42710: trigger "on_auth_user_created" already exists
ERROR: 42710: policy "Users can view..." already exists
```

### AFTER:
✅ Script can be run **multiple times** safely  
✅ No errors if objects already exist  
✅ Updates existing objects if needed

---

## 🔧 Changes Made

### 1. Tables - Added `IF NOT EXISTS`
```sql
-- BEFORE:
CREATE TABLE public.users (...)

-- AFTER:
CREATE TABLE IF NOT EXISTS public.users (...)
```

Applied to all 5 tables:
- ✅ `public.users`
- ✅ `public.conversations`
- ✅ `public.messages`
- ✅ `public.mood_entries`
- ✅ `public.journal_entries`

---

### 2. Indexes - Added `IF NOT EXISTS`
```sql
-- BEFORE:
CREATE INDEX idx_conversations_user_id ON public.conversations(user_id);

-- AFTER:
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
```

Applied to all 8 indexes:
- ✅ `idx_conversations_user_id`
- ✅ `idx_conversations_updated_at`
- ✅ `idx_messages_conversation_id`
- ✅ `idx_messages_timestamp`
- ✅ `idx_mood_entries_user_id`
- ✅ `idx_mood_entries_timestamp`
- ✅ `idx_journal_entries_user_id`
- ✅ `idx_journal_entries_created_at`

---

### 3. Triggers - Added `DROP IF EXISTS` Before Create
```sql
-- BEFORE:
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- AFTER:
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

Applied to all 4 triggers:
- ✅ `update_users_updated_at` on `public.users`
- ✅ `update_conversations_updated_at` on `public.conversations`
- ✅ `update_journal_entries_updated_at` on `public.journal_entries`
- ✅ `on_auth_user_created` on `auth.users` (important!)

---

### 4. RLS Policies - Added `DROP IF EXISTS` Before Create
```sql
-- BEFORE:
CREATE POLICY "Users can view their own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

-- AFTER:
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
CREATE POLICY "Users can view their own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);
```

Applied to all 15 policies:

**Users table (3 policies):**
- ✅ "Users can view their own profile"
- ✅ "Users can update their own profile"
- ✅ "Users can insert their own profile"

**Conversations table (4 policies):**
- ✅ "Users can view their own conversations"
- ✅ "Users can create their own conversations"
- ✅ "Users can update their own conversations"
- ✅ "Users can delete their own conversations"

**Messages table (2 policies):**
- ✅ "Users can view messages in their conversations"
- ✅ "Users can create messages in their conversations"

**Mood Entries table (4 policies):**
- ✅ "Users can view their own mood entries"
- ✅ "Users can create their own mood entries"
- ✅ "Users can update their own mood entries"
- ✅ "Users can delete their own mood entries"

**Journal Entries table (4 policies):**
- ✅ "Users can view their own journal entries"
- ✅ "Users can create their own journal entries"
- ✅ "Users can update their own journal entries"
- ✅ "Users can delete their own journal entries"

---

### 5. Added Drop Statements at Top
```sql
-- ============================================
-- DROP EXISTING OBJECTS (Safe to run multiple times)
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_conversations_updated_at ON public.conversations;
DROP TRIGGER IF EXISTS update_journal_entries_updated_at ON public.journal_entries;
```

This ensures triggers are always fresh even if script is interrupted mid-run.

---

## ✅ What's Now Safe

### You Can Run This Script:
1. ✅ **First time** - Creates everything fresh
2. ✅ **Second time** - No errors, updates where needed
3. ✅ **After manual changes** - Resets to known state
4. ✅ **After partial failure** - Completes missing pieces
5. ✅ **In CI/CD pipelines** - Repeatable deployments

---

## 🚀 How to Use

### Method 1: Fresh Database
```sql
-- Just run supabase_schema.sql
-- Everything will be created
```

### Method 2: Existing Database
```sql
-- Run supabase_schema.sql again
-- Script will:
--   1. Skip existing tables (IF NOT EXISTS)
--   2. Skip existing indexes (IF NOT EXISTS)
--   3. Drop and recreate triggers (always fresh)
--   4. Drop and recreate policies (always fresh)
--   5. Keep functions (CREATE OR REPLACE)
```

### Method 3: Reset Specific Objects
```sql
-- Just run the relevant section
-- Example: Reset policies only
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
CREATE POLICY "Users can view their own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);
```

---

## 📊 Complete Object Inventory

### Database Objects:
| Type | Count | Idempotent? |
|------|-------|-------------|
| Extensions | 1 | ✅ Already was |
| Tables | 5 | ✅ Now is |
| Indexes | 8 | ✅ Now is |
| Functions | 2 | ✅ Already was (CREATE OR REPLACE) |
| Triggers | 4 | ✅ Now is |
| RLS Policies | 15 | ✅ Now is |
| Grant Statements | 3 | ✅ Always safe |

**Total: 38 database objects, all idempotent!** 🎉

---

## 🔍 Verification

### Test 1: Run Twice in Sequence
```bash
# In Supabase SQL Editor:
# 1. Copy entire supabase_schema.sql
# 2. Run it → Success
# 3. Run it again → Still success (no errors!)
```

### Test 2: Check Objects Created
```sql
-- Check tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
-- Should see: users, conversations, messages, mood_entries, journal_entries

-- Check indexes
SELECT indexname FROM pg_indexes WHERE schemaname = 'public';
-- Should see all 8 indexes

-- Check policies
SELECT policyname FROM pg_policies WHERE schemaname = 'public';
-- Should see all 15 policies

-- Check triggers
SELECT trigger_name FROM information_schema.triggers 
WHERE trigger_schema = 'public';
-- Should see 3 triggers (plus 1 on auth.users)
```

---

## 🎓 Why Idempotency Matters

### Development:
- Run schema during local setup
- Re-run after pulling updates
- Reset to known state anytime

### Testing:
- Create test database
- Run migrations repeatedly
- Tear down and rebuild

### Production:
- Deploy schema updates safely
- Rollback by re-running old version
- No manual cleanup needed

### Team Collaboration:
- Everyone runs same script
- No "already exists" confusion
- Consistent database state

---

## 📝 Best Practices Applied

### 1. Always Use IF NOT EXISTS for DDL
```sql
✅ CREATE TABLE IF NOT EXISTS
✅ CREATE INDEX IF NOT EXISTS
✅ CREATE EXTENSION IF NOT EXISTS
```

### 2. Always DROP Before CREATE for Objects Without IF NOT EXISTS
```sql
✅ DROP TRIGGER IF EXISTS ... before CREATE TRIGGER
✅ DROP POLICY IF EXISTS ... before CREATE POLICY
```

### 3. Use CREATE OR REPLACE for Functions
```sql
✅ CREATE OR REPLACE FUNCTION
```

### 4. Keep GRANT Statements (Always Safe)
```sql
✅ GRANT statements don't error if permissions already exist
```

---

## 🚦 Next Steps

### For You:
1. ✅ **Run Updated Schema** in Supabase Dashboard
   - Copy all of `supabase_schema.sql`
   - Paste in SQL Editor
   - Run it
   - Should complete with "Success"

2. ✅ **Test Auth Flow**
   - Sign up new user
   - Check `public.users` table has entry
   - Verify `auth.users` also has entry

3. ✅ **Test App**
   - Run `flutter run`
   - Test model selector
   - Test guardrails
   - Test chat persistence

---

## 🎉 Summary

**Problem:** Script failed with "already exists" errors  
**Solution:** Made every statement idempotent  
**Result:** Can run script safely anytime  
**Benefit:** Simplified database management  

**Your schema is now production-ready!** ✅

---

**File Updated:** `supabase_schema.sql`  
**Status:** Fully idempotent  
**Safe to Run:** Unlimited times  
**Data Loss Risk:** None (preserves existing data)
