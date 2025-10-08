# LLM Model Selector - Visual Guide

## UI Location

```
┌─────────────────────────────────────────────────────┐
│  [≡]     [Mindful Companion ▼]        [New Chat]   │ ← Top Navigation Bar
│           └─ Click here to select model            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Chat messages appear here...                      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Model Selector Dropdown

When you click on "Mindful Companion ▼", a bottom sheet appears:

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Select AI Model                                    │
│  Choose which AI assistant you'd like to chat with │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │ 🧠  Mindful Companion                    ✓   │ │ ← Selected
│  │     Your personalized mental health assistant│ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │ ✨  Gemini Wisdom                             │ │
│  │     Powered by Google AI for broader insights│ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Model Cards Design

### Mindful Companion (Selected State)
```
┌─────────────────────────────────────────────────┐
│ Background: Light green (#E8F5E9)              │
│ Border: Green, 2px                              │
│                                                 │
│  🧠  (Psychology Icon - Green)                  │
│                                                 │
│  Mindful Companion                              │
│  Your personalized mental health assistant      │
│                                       ✓         │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Gemini Wisdom (Unselected State)
```
┌─────────────────────────────────────────────────┐
│ Background: Light gray (#F5F5F5)               │
│ Border: Transparent                             │
│                                                 │
│  ✨  (Auto-awesome Icon - Gray)                 │
│                                                 │
│  Gemini Wisdom                                  │
│  Powered by Google AI for broader insights      │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Interaction Flow

### 1. Initial State
- Top bar shows: "Mindful Companion ▼"
- Default model is Mindful Companion
- Connection status shown below

### 2. User Clicks Dropdown
- Bottom sheet slides up from bottom
- Shows all available models
- Current selection is highlighted in green

### 3. User Selects Model
- Taps on desired model card
- Bottom sheet closes
- Toast message appears: "Gemini Wisdom selected"
- Top bar updates to show new model name

### 4. Chatting
- All new messages use the selected model
- Model persists throughout the session
- Can switch anytime by clicking dropdown again

## Color Scheme

### Mindful Companion (Selected)
- **Background**: `#E8F5E9` (Light Green)
- **Border**: `Colors.green` (2px solid)
- **Icon**: `Colors.green`
- **Title**: `Colors.green[800]`
- **Description**: `Colors.green[700]`
- **Checkmark**: `Colors.green`

### Model Card (Unselected)
- **Background**: `#F5F5F5` (Light Gray)
- **Border**: `Colors.transparent`
- **Icon**: `Colors.grey`
- **Title**: `Colors.black`
- **Description**: `Colors.black54`

### Top Bar Button
- **Background**: `Colors.white`
- **Border**: `Colors.grey.shade300`
- **Text**: `Colors.black` (bold, 16px)
- **Icon**: `Colors.black87` (chevron down)
- **Padding**: 12px horizontal, 6px vertical
- **Border Radius**: 20px

## Responsive Behavior

### Mobile (≤768px width)
```
┌─────────────────────────┐
│ [≡] [Model ▼]  [New]   │
└─────────────────────────┘
```
- Compact layout
- Sidebar toggle on left
- Model name may be truncated if needed

### Desktop (>768px width)
```
┌──────────────────────────────────────────┐
│     [Mindful Companion ▼]      [New Chat]│
└──────────────────────────────────────────┘
```
- Full model name visible
- More spacing
- No sidebar toggle

## Model Icons

### Mindful Companion
- **Icon**: `Icons.psychology` (brain/mental health)
- **Size**: 32px
- **Color**: Green when selected, gray when not

### Gemini Wisdom
- **Icon**: `Icons.auto_awesome` (sparkle/AI)
- **Size**: 32px
- **Color**: Green when selected, gray when not

## Animation & Feedback

### Bottom Sheet
- **Entry**: Slides up from bottom with smooth animation
- **Exit**: Slides down when model selected or tapped outside
- **Background**: Semi-transparent overlay

### Model Selection
- **Tap Feedback**: Visual ripple effect
- **State Change**: Immediate UI update
- **Toast Notification**: 
  - Text: "{Model Name} selected"
  - Duration: SHORT (2 seconds)
  - Position: BOTTOM
  - Background: Green
  - Text: White

### Dropdown Button
- **Hover**: Slight scale or shadow effect (if applicable)
- **Tap**: No visual feedback needed (bottom sheet provides feedback)

## Accessibility

### Labels
- Dropdown button has semantic label
- Each model card is tappable
- Clear visual hierarchy

### Text Sizes
- Model name: 16px (bold)
- Model description: 13px (regular)
- Bottom sheet title: 20px (bold)
- Bottom sheet subtitle: 14px (regular)

### Contrast
- All text has sufficient contrast ratio
- Selected state is clearly distinguishable
- Icons are visible in both states

## User Journey Example

```
User opens app
    ↓
Sees "Mindful Companion ▼" at top
    ↓
Clicks on model name
    ↓
Bottom sheet appears with 2 models
    ↓
Taps "Gemini Wisdom"
    ↓
Bottom sheet closes
    ↓
Toast shows "Gemini Wisdom selected"
    ↓
Top bar updates to "Gemini Wisdom ▼"
    ↓
User sends message
    ↓
Message processed by Gemini API
    ↓
Response appears in chat
```

## Edge Cases Handled

### 1. Model Unavailable
- Future enhancement: Gray out unavailable models
- Show status indicator

### 2. Network Issues
- Error messages are model-agnostic
- User can try switching models

### 3. API Failures
- Graceful error handling
- Doesn't change selected model
- User can retry or switch

### 4. Mid-Conversation Switch
- Context is maintained
- New model has access to recent messages
- Smooth transition without losing chat history

---

**Design Philosophy**: Clean, intuitive, and focused on user control while maintaining the mental health app's calming aesthetic.
