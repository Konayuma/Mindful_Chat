# Gemini Model Name Update

## Issue
The v1 API doesn't recognize `gemini-1.5-flash` without the `-latest` suffix.

## Fix Applied
Changed model name to: `gemini-1.5-flash-latest`

## Test Now
1. Hot reload (press `r`)
2. Try asking: "What is mental health?"
3. Should work now!

## If Still 404
The Gemini API endpoints keep changing. If this doesn't work, we may need to use v1beta instead of v1 with a different model.
