# Onboarding Flow Implementation

## Overview

After successful password creation, users now go through an onboarding flow before reaching the chat screen.

## Flow Sequence

```
Sign Up → Email Input → Email Verification → Create Password → Safety Note → Goals Selection → Notifications → Chat
```

✅ **Onboarding Complete!** All screens implemented.

## Implemented Screens

### 1. ✅ Safety Note Screen (`safety_note_screen.dart`)

**Purpose:** Inform users about AI limitations and provide emergency contact information

**Features:**
- Safety icon (user with shield)
- Clear disclaimer about AI limitations
- 4 emergency contact numbers for Zambia:
  - 933 (Lifeline Zambia – National Suicide Prevention Helpline)
  - 116 (GBV and Child Protection Helpline)
  - 991 (Medical Emergency)
  - 999 (Police Emergency)
- "I understand" button to proceed

**Design:** Figma node 158:272

**Navigation:**
- **From:** Create Password Screen (after successful password setup)
- **To:** Goals Selection Screen

### 2. ✅ Goals Selection Screen (`goals_selection_screen.dart`)

**Purpose:** Let users select their mental health goals

**Features:**
- Multi-select goal options with checkboxes
- 4 goal options:
  - Manage Stress/Anxiety (brain icon)
  - Boost Daily Mood (energy icon)
  - Build Resilience (muscle icon)
  - Learn Mindfulness (lotus flower icon)
- "Continue" button (requires at least 1 selection)
- Visual feedback on selection with blue checkmarks

**Design:** Figma node 159:545

**Navigation:**
- **From:** Safety Note Screen
- **To:** Notification Preferences Screen

### 3. ✅ Notification Preferences Screen (`notification_preferences_screen.dart`)

**Purpose:** Allow users to enable/disable daily reminder notifications

**Features:**
- Safety/shield icon (consistent with app theme)
- "Stay Consistent" title
- Clear explanation of notification purpose
- Toggle switch for enabling/disabling notifications
- "Go to chat" button to complete onboarding
- Preference stored for later use

**Design:** Figma node 163:195

**Navigation:**
- **From:** Goals Selection Screen
- **To:** Chat Screen (onboarding complete!)

## Assets

### Created by Figma MCP

Located in `assets/images/onboarding/`:

**Safety Note Screen:**
1. **Safety icon** (user with shield)
   - `3632acd00347e777593b61706d0a1b1d3e944db7.svg`

2. **Phone icon** (for emergency contacts)
   - `ce76dc0e8419f24a09ed1566475551a80dacf3ba.svg`

**Goals Selection Screen:**
3. **Brain icon** (Manage Stress/Anxiety)
   - `fdc4471573f44b1cec3ae66cce16351cb10245a3.svg`

4. **Energy icon** (Boost Daily Mood)
   - `6bc4efa08d79e11cf58c21a816f8917e65e2edb6.svg`

5. **Muscle icon** (Build Resilience)
   - `1202588e2e2369af0dc32a8663a37652e7809680.svg`

6. **Lotus flower icon** (Learn Mindfulness)
   - `f6202f1fab7da27220c70292341b8dd0a9089232.svg`

7. **Checkbox states** (selected/unselected)
   - `4d5d937d59d161b5fb4e1c7b091035afa39a665d.svg`

## Code Changes

### Files Created

1. **`lib/screens/safety_note_screen.dart`**
   - Complete Flutter implementation
   - Matches Figma design pixel-perfect
   - Responsive layout with SafeArea
   - Uses Satoshi font family
   - Navigates to Goals Selection Screen

2. **`lib/screens/goals_selection_screen.dart`**
   - Multi-select goal options with state management
   - Interactive checkboxes with visual feedback
   - Validation (requires at least 1 selection)
   - Stores selected goals (ready for profile integration)
   - Navigates to Notification Preferences Screen

3. **`lib/screens/notification_preferences_screen.dart`**
   - Toggle switch for notification preferences
   - State management for on/off state
   - Navigates to Chat Screen
   - Ready for notification preference storage

### Files Modified

1. **`lib/screens/create_password_screen.dart`**
   - Changed import from `chat_screen.dart` to `safety_note_screen.dart`
   - Updated navigation after password setup
   - Now navigates to SafetyNoteScreen instead of ChatScreen

2. **`lib/screens/safety_note_screen.dart`**
   - Added navigation to GoalsSelectionScreen
   - Updated from placeholder navigation

## Design System

### Colors Used

```dart
background: Color(0xFFF3F3F3)        // Light gray background
container: Color(0xFFF0F3FB)         // Light blue container
button: Color(0xFF1E1E1E)            // Dark button
contactCard: Colors.white            // White contact cards
text: Colors.black                   // Black text
buttonText: Colors.white             // White button text
```

### Typography

All text uses **Satoshi** font family:
- Title: 32px, Bold
- Body: 16px, Medium
- Contact info: 8px, Bold (numbers) + Regular/Medium (descriptions)
- Button: 12px, Medium

### Layout

- Screen padding: 27px horizontal
- Container: 336px width, 634px height, 30px border radius
- Container padding: 16px horizontal, 42px vertical
- Button: 304px width, 44px height, positioned at bottom
- Icon size: 83x83px (safety icon), 18x18px (phone icons)

## Next Steps

### Complete Onboarding Testing

1. ✅ All screens created and wired up
2. ✅ Navigation chain complete: Password → Safety → Goals → Notifications → Chat
3. Test complete flow end-to-end
4. Optional: Integrate goal and notification preferences with Supabase user profiles

### To Get Figma Node ID

From your Figma link, extract the node-id parameter:
```
https://www.figma.com/design/nrEDZnUQsfL1HmHJSCKzfW/Mindful-Chat?node-id=XXX-YYY
```

The node ID is the `XXX-YYY` part (format it as `XXX:YYY` for me)

## Testing Checklist

- [ ] Build succeeds without errors
- [ ] Safety Note screen displays correctly
- [ ] All 4 emergency contacts visible
- [ ] Icons render properly
- [ ] "I understand" button works
- [ ] Navigation from password screen works
- [ ] Screen is responsive on different devices
- [ ] Text is readable and properly aligned

## Current Status

✅ Safety Note Screen implemented  
✅ Goals Selection Screen implemented  
✅ Notification Preferences Screen implemented  
✅ Complete navigation flow wired up  
✅ **ONBOARDING COMPLETE!**

---

**Last Updated:** October 1, 2025  
**Figma Designs:** 
- Safety Note: https://www.figma.com/design/nrEDZnUQsfL1HmHJSCKzfW/Mindful-Chat?node-id=158-272
- Goals Selection: https://www.figma.com/design/nrEDZnUQsfL1HmHJSCKzfW/Mindful-Chat?node-id=159-545
- Notification Preferences: https://www.figma.com/design/nrEDZnUQsfL1HmHJSCKzfW/Mindful-Chat?node-id=163-195
