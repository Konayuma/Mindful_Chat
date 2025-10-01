-- Email Verification Codes Table
-- Add this to your existing supabase_schema.sql or run separately

-- Create verification_codes table
CREATE TABLE IF NOT EXISTS verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    code TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT code_length CHECK (length(code) = 6)
);

-- Create index for fast lookups
CREATE INDEX IF NOT EXISTS idx_verification_codes_email 
    ON verification_codes(email);
CREATE INDEX IF NOT EXISTS idx_verification_codes_expires 
    ON verification_codes(expires_at);
CREATE INDEX IF NOT EXISTS idx_verification_codes_verified 
    ON verification_codes(verified);

-- Enable Row Level Security
ALTER TABLE verification_codes ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Anyone can insert (for sending codes)
CREATE POLICY "Anyone can insert verification codes" 
    ON verification_codes 
    FOR INSERT 
    TO public 
    WITH CHECK (true);

-- RLS Policy: Anyone can read their own codes (for verification)
CREATE POLICY "Users can read their verification codes" 
    ON verification_codes 
    FOR SELECT 
    TO public 
    USING (true);

-- RLS Policy: Anyone can update their own codes (for marking as verified)
CREATE POLICY "Users can update their verification codes" 
    ON verification_codes 
    FOR UPDATE 
    TO public 
    USING (true);

-- Function to automatically delete expired codes (optional)
-- You can call this manually or set up a scheduled job
CREATE OR REPLACE FUNCTION delete_expired_verification_codes()
RETURNS void AS $$
BEGIN
    DELETE FROM verification_codes
    WHERE expires_at < NOW() AND verified = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Optional: Create a scheduled job to clean up expired codes every hour
-- This requires the pg_cron extension (available in Supabase Pro)
-- Uncomment the following lines if you want automatic cleanup:

-- SELECT cron.schedule(
--     'delete-expired-verification-codes',
--     '0 * * * *', -- Every hour
--     'SELECT delete_expired_verification_codes();'
-- );
