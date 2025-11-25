-- ============================================
-- She-Inspires Features Integration Schema
-- Mental Health App - Bookmarks, Affirmations, Enhanced Journal
-- ============================================

-- ============================================
-- BOOKMARKS TABLE
-- Users can save affirmations, chat messages, and journal entries
-- ============================================
CREATE TABLE IF NOT EXISTS public.bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('affirmation', 'message', 'journal')),
    payload_json JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

-- RLS Policies for bookmarks
DROP POLICY IF EXISTS "Users can view their own bookmarks" ON public.bookmarks;
CREATE POLICY "Users can view their own bookmarks"
    ON public.bookmarks FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create their own bookmarks" ON public.bookmarks;
CREATE POLICY "Users can create their own bookmarks"
    ON public.bookmarks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own bookmarks" ON public.bookmarks;
CREATE POLICY "Users can update their own bookmarks"
    ON public.bookmarks FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own bookmarks" ON public.bookmarks;
CREATE POLICY "Users can delete their own bookmarks"
    ON public.bookmarks FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- AFFIRMATIONS TABLE (Optional - for remote sync)
-- Store daily affirmations with metadata
-- ============================================
CREATE TABLE IF NOT EXISTS public.affirmations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    author TEXT,
    category TEXT DEFAULT 'general',
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

-- Enable Row Level Security (public read, admin write)
ALTER TABLE public.affirmations ENABLE ROW LEVEL SECURITY;

-- RLS Policies for affirmations (everyone can read active affirmations)
DROP POLICY IF EXISTS "Anyone can view active affirmations" ON public.affirmations;
CREATE POLICY "Anyone can view active affirmations"
    ON public.affirmations FOR SELECT
    USING (is_active = TRUE);

-- ============================================
-- USER AFFIRMATION PREFERENCES
-- Track user's favorite affirmations and preferences
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_affirmation_prefs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    notification_enabled BOOLEAN DEFAULT FALSE,
    notification_time TIME DEFAULT '09:00:00',
    last_shown_date DATE,
    last_affirmation_id UUID REFERENCES public.affirmations(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE public.user_affirmation_prefs ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_affirmation_prefs
DROP POLICY IF EXISTS "Users can view their own affirmation preferences" ON public.user_affirmation_prefs;
CREATE POLICY "Users can view their own affirmation preferences"
    ON public.user_affirmation_prefs FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own affirmation preferences" ON public.user_affirmation_prefs;
CREATE POLICY "Users can insert their own affirmation preferences"
    ON public.user_affirmation_prefs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own affirmation preferences" ON public.user_affirmation_prefs;
CREATE POLICY "Users can update their own affirmation preferences"
    ON public.user_affirmation_prefs FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id ON public.bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_type ON public.bookmarks(type);
CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at ON public.bookmarks(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_affirmations_category ON public.affirmations(category);
CREATE INDEX IF NOT EXISTS idx_affirmations_is_active ON public.affirmations(is_active);
CREATE INDEX IF NOT EXISTS idx_user_affirmation_prefs_user_id ON public.user_affirmation_prefs(user_id);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

-- Trigger for bookmarks table
DROP TRIGGER IF EXISTS update_bookmarks_updated_at ON public.bookmarks;
CREATE TRIGGER update_bookmarks_updated_at
    BEFORE UPDATE ON public.bookmarks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for user_affirmation_prefs table
DROP TRIGGER IF EXISTS update_user_affirmation_prefs_updated_at ON public.user_affirmation_prefs;
CREATE TRIGGER update_user_affirmation_prefs_updated_at
    BEFORE UPDATE ON public.user_affirmation_prefs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SEED AFFIRMATIONS DATA
-- Mental health focused affirmations
-- ============================================
INSERT INTO public.affirmations (content, author, category, tags) VALUES
('I am worthy of love and care, especially from myself.', 'Mindful Chat', 'self-love', ARRAY['self-love', 'affirmation', 'worth']),
('My feelings are valid and deserve to be acknowledged.', 'Mindful Chat', 'emotions', ARRAY['emotions', 'validation', 'feelings']),
('I am stronger than my anxiety and can face my fears one step at a time.', 'Mindful Chat', 'anxiety', ARRAY['anxiety', 'courage', 'strength']),
('It''s okay to rest. My worth is not defined by my productivity.', 'Mindful Chat', 'self-care', ARRAY['rest', 'self-care', 'worth']),
('I choose to be patient with myself as I grow and heal.', 'Mindful Chat', 'healing', ARRAY['healing', 'patience', 'growth']),
('My mental health matters and taking care of it is a priority.', 'Mindful Chat', 'mental-health', ARRAY['mental-health', 'priority', 'self-care']),
('I am allowed to take up space and express my needs.', 'Mindful Chat', 'boundaries', ARRAY['boundaries', 'needs', 'self-worth']),
('Every small step forward is progress worth celebrating.', 'Mindful Chat', 'progress', ARRAY['progress', 'growth', 'celebration']),
('I release what I cannot control and focus on what I can.', 'Mindful Chat', 'control', ARRAY['control', 'acceptance', 'peace']),
('I am doing the best I can with what I have right now.', 'Mindful Chat', 'self-compassion', ARRAY['self-compassion', 'acceptance', 'kindness']),
('My mental health journey is unique and valid.', 'Mindful Chat', 'mental-health', ARRAY['mental-health', 'journey', 'validation']),
('I deserve peace, joy, and happiness in my life.', 'Mindful Chat', 'happiness', ARRAY['happiness', 'peace', 'joy']),
('I am not my thoughts; I can observe them without judgment.', 'Mindful Chat', 'mindfulness', ARRAY['mindfulness', 'thoughts', 'awareness']),
('It''s okay to ask for help. Seeking support is a sign of strength.', 'Mindful Chat', 'support', ARRAY['support', 'help', 'strength']),
('I trust in my ability to navigate difficult emotions.', 'Mindful Chat', 'emotions', ARRAY['emotions', 'trust', 'resilience']),
('Today, I choose to be kind to myself.', 'Mindful Chat', 'self-compassion', ARRAY['self-compassion', 'kindness', 'choice']),
('I am making space for healing in my life.', 'Mindful Chat', 'healing', ARRAY['healing', 'space', 'growth']),
('My vulnerability is a strength, not a weakness.', 'Mindful Chat', 'vulnerability', ARRAY['vulnerability', 'strength', 'courage']),
('I am allowed to feel all my emotions without guilt.', 'Mindful Chat', 'emotions', ARRAY['emotions', 'feelings', 'acceptance']),
('I am creating a life that feels good on the inside, not just one that looks good on the outside.', 'Mindful Chat', 'authenticity', ARRAY['authenticity', 'inner-peace', 'life']),
('Each breath I take brings me closer to calm.', 'Mindful Chat', 'breathing', ARRAY['breathing', 'calm', 'mindfulness']),
('I honor my boundaries and respect my limits.', 'Mindful Chat', 'boundaries', ARRAY['boundaries', 'respect', 'limits']),
('My past does not define my future.', 'Mindful Chat', 'growth', ARRAY['growth', 'past', 'future']),
('I give myself permission to rest without guilt.', 'Mindful Chat', 'rest', ARRAY['rest', 'permission', 'self-care']),
('I am committed to my healing journey, one day at a time.', 'Mindful Chat', 'healing', ARRAY['healing', 'commitment', 'journey']),
('I choose progress over perfection.', 'Mindful Chat', 'progress', ARRAY['progress', 'perfection', 'growth']),
('My self-care is non-negotiable.', 'Mindful Chat', 'self-care', ARRAY['self-care', 'priority', 'boundaries']),
('I am capable of creating positive change in my life.', 'Mindful Chat', 'change', ARRAY['change', 'capability', 'positive']),
('I release the need to control everything and trust the process.', 'Mindful Chat', 'control', ARRAY['control', 'trust', 'acceptance']),
('I am enough, exactly as I am right now.', 'Mindful Chat', 'self-worth', ARRAY['self-worth', 'enough', 'acceptance'])
ON CONFLICT DO NOTHING;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================
GRANT ALL ON public.bookmarks TO authenticated;
GRANT SELECT ON public.affirmations TO anon, authenticated;
GRANT ALL ON public.user_affirmation_prefs TO authenticated;

-- ============================================
-- DONE! She-Inspires schema is ready.
-- ============================================
