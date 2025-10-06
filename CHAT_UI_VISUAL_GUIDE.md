# Chat Interface Visual Guide

## 🎨 New UI Layout

### Desktop View (Wide Screen)
```
┏━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃              ┃  [☰] Mental Health Chat    [+ New]    ┃
┃   SIDEBAR    ┃        Connected ●                     ┃
┃   (280px)    ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃              ┃                                        ┃
┃ ┌──────────┐ ┃  💬 AI: Hello! I'm here to help...   ┃
┃ │  Search  │ ┃                                        ┃
┃ └──────────┘ ┃  👤 User: How do I manage stress?     ┃
┃              ┃                                        ┃
┃  [+ New Chat]┃  💬 AI: Great question! Here are...   ┃
┃              ┃                                        ┃
┃ Recent Chats ┃                                        ┃
┃  💬 Anxiety  ┃                                        ┃
┃  💬 Sleep    ┃                                        ┃
┃  💬 Stress   ┃                                        ┃
┃              ┃                                        ┃
┃              ┃  ┌──────────────────────────┐ 📤      ┃
┃              ┃  │ Ask about mental health...│ [Send] ┃
┃ ─────────────┃  └──────────────────────────┘        ┃
┃              ┃                                        ┃
┃  👤 Profile  ┃                                        ┃
┃  user@email  ┃                                        ┃
┃      ⋮       ┃                                        ┃
┗━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### Mobile View (Narrow Screen)
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ [☰] Mental Health Chat    [+ New]┃
┃       Connected ●                 ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃                                   ┃
┃  💬 AI: Hello! I'm here to help  ┃
┃                                   ┃
┃           👤 User: Hi there!     ┃
┃                                   ┃
┃  💬 AI: How can I assist you?    ┃
┃                                   ┃
┃                                   ┃
┃                                   ┃
┃  ┌─────────────────────┐ 📤      ┃
┃  │ Type message...     │ [Send]  ┃
┃  └─────────────────────┘         ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Tap [☰] → Drawer slides in:
┏━━━━━━━━━━━━━━━━━━━━┓
┃  ┌──────────────┐  ┃
┃  │   Search     │  ┃
┃  └──────────────┘  ┃
┃                    ┃
┃   [+ New Chat]     ┃
┃                    ┃
┃  Recent Chats      ┃
┃   💬 Anxiety       ┃
┃   💬 Sleep         ┃
┃   💬 Stress        ┃
┃                    ┃
┃  ─────────────     ┃
┃                    ┃
┃   👤 Profile       ┃
┃   user@email   ⋮   ┃
┗━━━━━━━━━━━━━━━━━━━━┛
```

## 🎯 Key UI Elements

### 1. Top Navigation Bar
```
┌────────────────────────────────────────────┐
│ [☰]  Mental Health Chat          [+ New]  │
│            Connected ●                     │
└────────────────────────────────────────────┘
```
- **Left**: Sidebar icon (mobile only)
- **Center**: Title + connection status
- **Right**: New chat button
- **Color**: #F3F3F3 (matches chat background)

### 2. Sidebar/Drawer
```
┌──────────────────────┐
│  ┌────────────────┐  │
│  │ Search chats...│  │
│  └────────────────┘  │
│                      │
│  ╔═══════════════╗  │
│  ║  + New Chat   ║  │ ← Black button
│  ╚═══════════════╝  │
│                      │
│  Recent Chats        │ ← Gray header
│  ├─ 💬 Chat 1        │
│  ├─ 💬 Chat 2        │
│  └─ 💬 Chat 3        │
│                      │
│  ─────────────────   │
│                      │
│  👤 John Doe         │ ← Clickable
│  john@email.com  ⋮   │
└──────────────────────┘
```

### 3. Profile Menu (Bottom Sheet)
```
Tap profile section →

        ╔═══════════════════╗
        ║                   ║
        ║  ⚙️  Settings     ║
        ║                   ║
        ║  👤 Profile       ║
        ║                   ║
        ║  ─────────────    ║
        ║                   ║
        ║  🚪 Sign Out      ║ ← Red text
        ║                   ║
        ╚═══════════════════╝
```

### 4. New Chat Button Styles

**In Navbar (Top Right):**
```
┌─────────┐
│ [+] New │ ← Black background
└─────────┘   White icon
```

**In Sidebar:**
```
┌────────────────────┐
│  [+]  New Chat     │ ← Full width button
└────────────────────┘   Black background
                         White text & icon
```

## 🎨 Color Palette

### Background Colors
```css
Chat Background:     #F3F3F3 (Light Gray)
Navbar Background:   #F3F3F3 (Matches chat)
Sidebar Background:  #FFFFFF (White)
```

### Message Bubbles
```css
User Message:        Black bg + White text
AI Message:          White bg + Black text
Both have shadow:    rgba(0,0,0,0.1)
```

### Buttons & Accents
```css
Primary Button:      #000000 (Black)
Button Text:         #FFFFFF (White)
Sign Out:            #FF0000 (Red)
Connected Status:    #00FF00 (Green)
Offline Status:      #FF0000 (Red)
```

## 📱 Interaction Flows

### Opening Sidebar (Mobile)
```
1. Tap [☰] icon in navbar
   ↓
2. Drawer slides in from left
   ↓
3. Access all sidebar features
   ↓
4. Tap outside or back to close
```

### Starting New Chat
```
Method 1: Navbar Button
Click [+ New] in top right
   ↓
Messages clear
   ↓
Welcome message appears

Method 2: Sidebar Button
Click [+ New Chat] in sidebar
   ↓
Messages clear
   ↓
Welcome message appears
```

### Accessing Profile Options
```
1. Click profile section (bottom of sidebar)
   ↓
2. Bottom sheet slides up
   ┌─────────────┐
   │  Settings   │
   │  Profile    │
   │  ─────────  │
   │  Sign Out   │
   └─────────────┘
   ↓
3. Select option
   ↓
4. Action executes
```

### Searching Chats
```
1. Click search bar in sidebar
   ↓
2. Type search query
   ↓
3. Results filter in real-time
   (Feature ready, needs backend)
```

## 🔧 Technical Components

### Responsive Layout
```dart
if (MediaQuery.of(context).size.width > 768)
  _buildLeftSidebar()  // Desktop: Always visible
else
  drawer: _buildSideNavDrawer()  // Mobile: Drawer
```

### SVG Icons
```dart
// Sidebar toggle
SvgPicture.asset('assets/images/sidebar.svg')

// New chat
SvgPicture.asset('assets/images/pajamas_duo-chat-new.svg')
```

### Profile Menu Trigger
```dart
InkWell(
  onTap: () => _showProfileMenu(context),
  child: ProfileSection(),
)
```

## 📊 Layout Measurements

### Desktop
- **Sidebar Width**: 280px
- **Chat Area**: Remaining space (flexible)
- **Navbar Height**: ~72px
- **Profile Section Height**: ~72px

### Mobile
- **Full Width**: 100%
- **Drawer Width**: ~280px (70-80% of screen)
- **Navbar Height**: ~72px

### Common
- **Message Padding**: 16px all sides
- **Border Radius**: 20px (bubbles), 25px (inputs)
- **Avatar Size**: 32px (messages), 40px (profile)

## 🎬 Animations

1. **Drawer Slide**: Smooth left-to-right transition
2. **Bottom Sheet**: Slide up from bottom with rounded top
3. **Button Press**: Scale/opacity feedback
4. **Chat Load**: Smooth scroll to bottom

## ✨ Visual Hierarchy

```
High Importance:
  1. Message input (always visible)
  2. New chat button (prominent, black)
  3. Chat messages (center focus)

Medium Importance:
  4. Search bar (top of sidebar)
  5. Recent chats (easy access)
  6. Connection status (informative)

Low Importance:
  7. Profile section (bottom, accessible)
  8. Settings/options (behind profile menu)
```

## 🎯 User Experience Goals

1. ✅ **Quick Access**: New chat always 1 tap away
2. ✅ **Easy Navigation**: Clear sidebar structure
3. ✅ **Clean Design**: No clutter, focused on chat
4. ✅ **Consistent**: Same experience across devices
5. ✅ **Intuitive**: Familiar patterns (drawer, bottom sheet)
6. ✅ **Accessible**: Profile and settings easy to find
