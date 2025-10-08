-- ============================================
-- CHAT HISTORY DIAGNOSTIC QUERIES
-- Run these in Supabase SQL Editor to check your database
-- ============================================

-- 1. Check if users exist in public.users table
SELECT 
    id,
    email,
    display_name,
    created_at,
    'User exists in public.users ✅' as status
FROM public.users
ORDER BY created_at DESC;

-- Expected: Should show your user account(s)
-- If empty: This is the problem! User profile not created.

-- ============================================

-- 2. Check all conversations
SELECT 
    c.id as conversation_id,
    c.user_id,
    u.email as user_email,
    c.title,
    c.created_at,
    c.is_archived,
    COUNT(m.id) as message_count
FROM public.conversations c
LEFT JOIN public.users u ON c.user_id = u.id
LEFT JOIN public.messages m ON m.conversation_id = c.id
GROUP BY c.id, c.user_id, u.email, c.title, c.created_at, c.is_archived
ORDER BY c.created_at DESC;

-- Expected: Shows all conversations with message counts
-- If empty: No conversations created yet (this was your issue)

-- ============================================

-- 3. Check messages in conversations
SELECT 
    m.id as message_id,
    c.title as conversation_title,
    m.content,
    m.is_user_message,
    m.timestamp,
    u.email as user_email
FROM public.messages m
JOIN public.conversations c ON m.conversation_id = c.id
JOIN public.users u ON c.user_id = u.id
ORDER BY m.timestamp DESC
LIMIT 20;

-- Expected: Shows recent messages
-- If empty: No messages saved yet

-- ============================================

-- 4. Find orphaned conversations (without user in public.users)
-- This query finds conversations that reference non-existent users
SELECT 
    c.id as conversation_id,
    c.user_id,
    c.title,
    c.created_at,
    'ORPHANED - No user in public.users ❌' as status
FROM public.conversations c
LEFT JOIN public.users u ON c.user_id = u.id
WHERE u.id IS NULL;

-- Expected: Should be empty after fix
-- If not empty: These conversations are orphaned and can't be accessed

-- ============================================

-- 5. Check RLS policies are working
-- This shows which policies exist and are enabled
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('users', 'conversations', 'messages')
ORDER BY tablename, policyname;

-- Expected: Should show multiple policies for each table
-- If empty: RLS policies not set up correctly

-- ============================================

-- 6. Quick summary of database state
SELECT 
    'Total Users' as metric,
    COUNT(*)::text as count
FROM public.users
UNION ALL
SELECT 
    'Total Conversations' as metric,
    COUNT(*)::text as count
FROM public.conversations
UNION ALL
SELECT 
    'Total Messages' as metric,
    COUNT(*)::text as count
FROM public.messages
UNION ALL
SELECT 
    'Archived Conversations' as metric,
    COUNT(*)::text as count
FROM public.conversations
WHERE is_archived = true;

-- Expected: Shows overall database statistics

-- ============================================

-- 7. Find users without any conversations
SELECT 
    u.id,
    u.email,
    u.display_name,
    u.created_at,
    'User has no conversations' as status
FROM public.users u
LEFT JOIN public.conversations c ON u.id = c.user_id
WHERE c.id IS NULL;

-- Expected: Shows users who haven't started any chats yet
-- This is normal for new users

-- ============================================

-- 8. Check auth.users vs public.users sync
-- This finds users in auth but not in public
SELECT 
    au.id,
    au.email,
    au.created_at as auth_created_at,
    'In auth.users but NOT in public.users ❌' as status
FROM auth.users au
LEFT JOIN public.users pu ON au.id = pu.id
WHERE pu.id IS NULL;

-- Expected: Should be empty after fix
-- If not empty: These users need profiles created

-- ============================================

-- CLEANUP QUERIES (Optional - only if needed)
-- ============================================

-- Clean up orphaned conversations (conversations without valid users)
-- UNCOMMENT TO RUN:
-- DELETE FROM public.conversations
-- WHERE user_id NOT IN (SELECT id FROM public.users);

-- Create missing user profiles from auth.users
-- UNCOMMENT TO RUN:
-- INSERT INTO public.users (id, email, display_name, created_at, updated_at)
-- SELECT 
--     id,
--     email,
--     raw_user_meta_data->>'display_name' as display_name,
--     created_at,
--     updated_at
-- FROM auth.users
-- WHERE id NOT IN (SELECT id FROM public.users)
-- ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TESTING QUERIES
-- ============================================

-- Test: Create a user profile manually
-- UNCOMMENT AND REPLACE [USER_ID] and [EMAIL]:
-- INSERT INTO public.users (id, email, display_name)
-- VALUES (
--     '[USER_ID]'::uuid,
--     '[EMAIL]',
--     'Test User'
-- )
-- ON CONFLICT (id) DO NOTHING;

-- Test: Create a test conversation
-- UNCOMMENT AND REPLACE [USER_ID]:
-- INSERT INTO public.conversations (user_id, title)
-- VALUES (
--     '[USER_ID]'::uuid,
--     'Test Conversation'
-- );

-- Test: Check if conversation creation works
-- UNCOMMENT AND REPLACE [USER_ID]:
-- WITH new_conversation AS (
--     INSERT INTO public.conversations (user_id, title)
--     VALUES ('[USER_ID]'::uuid, 'Test Conversation ' || NOW())
--     RETURNING *
-- )
-- SELECT 
--     'Conversation created successfully ✅' as status,
--     * 
-- FROM new_conversation;

-- ============================================
-- INTERPRETATION GUIDE
-- ============================================

/*
QUERY 1: Check users
- If empty → No user profiles exist, this is the root cause
- If has data → Good, user profiles exist

QUERY 2: Check conversations  
- If empty → No conversations created yet
- If has data but message_count = 0 → Conversations exist but no messages saved
- If has data with message_count > 0 → Everything working!

QUERY 3: Check messages
- If empty → No messages saved to database
- If has data → Messages being saved correctly

QUERY 4: Orphaned conversations
- If has data → These conversations are broken (no valid user)
- If empty → Good, all conversations have valid users

QUERY 8: Auth sync check
- If has data → These users need profiles created (this was your issue!)
- If empty → All auth users have profiles in public.users

NEXT STEPS:
1. Run Query 1 and 8 first to diagnose the issue
2. If users missing, the app will now auto-create them on next message
3. Run Query 2 after sending a message to verify conversation created
4. Run Query 6 for a quick overview
*/
