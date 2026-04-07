# Changelog

All notable changes to the Mindful Chat project will be documented in this file.

## [2025-04-07] - Version 1.1.0

### Major New Features
- **Complete Screen Suite**: Added all major screens for comprehensive mental health app experience
- **Breathing Exercise Screen**: Interactive breathing exercises with animated visual feedback and customizable cycles
- **Meditation Screen**: Guided meditation sessions with categories, duration options, and beautiful UI
- **Journal Screen**: Full-featured journaling with mood tracking, writing interface, and entry management
- **Mood Check-in Screen**: Multi-step mood assessment with emoji selection and feelings tracking
- **Enhanced Home Screen**: Improved navigation, animations, and full bottom navigation support

### Navigation & Routing
- **Fixed Navigation State**: Resolved navigation bug where only 2 of 5 bottom nav items worked correctly
- **Complete Route System**: Added named routes for all major screens (`/breathing`, `/meditation`, `/journal`, `/mood-checkin`, `/crisis`, `/articles`)
- **Profile Integration**: Profile screen now accessible from both bottom nav and top nav
- **Resources Hub**: Centralized resources screen with meditation, breathing, crisis support, and articles

### UI/UX Improvements
- **Animated Interactions**: Added smooth animations, transitions, and micro-interactions throughout
- **Enhanced Home Screen**: 
  - Animated breathing circle in add button
  - Improved card hover states and transitions
  - Better visual hierarchy and spacing
  - Mount checks for safe navigation
- **Responsive Design**: All screens properly adapt to different screen sizes
- **Dark Mode Enhancement**: Consistent dark theme across all new screens

### Technical Improvements
- **Code Quality**: Added proper error handling, mount checks, and controller disposal
- **Performance**: Optimized animations and reduced unnecessary rebuilds
- **Architecture**: Clean separation of concerns with dedicated screen files
- **Merge Conflict Resolution**: Fixed all git merge conflicts in main.dart and home_screen.dart

### Screen Features
- **Breathing Exercise**:
  - 4-2-4-2 breathing pattern (inhale-hold-exhale-rest)
  - Customizable cycle count
  - Visual breathing animation with progress tracking
  - Completion dialog with option to continue
  
- **Meditation**:
  - 6 different meditation categories
  - Session cards with duration and difficulty
  - Animated gradient background
  - Category filtering system
  
- **Journal**:
  - Mood selection with 6 emotion types
  - Rich text entry with title and content
  - Entry history with mood indicators
  - Floating action button with animation
  
- **Mood Check-in**:
  - 3-step process (mood → feelings → notes)
  - Visual mood selection with emojis
  - Multi-select feelings chips
  - Progress indicator

### Bug Fixes
- **Navigation Crash**: Fixed app crash when accessing Resources, Profile, or Add tabs
- **Merge Conflicts**: Resolved all git merge conflicts in core files
- **Memory Leaks**: Added proper controller disposal in all animation controllers
- **Safe Navigation**: Added mount checks before all navigation operations

## [2025-04-07] - Version 1.0.1

### Fixed
- **Home Screen Implementation**: Created new home screen (`home_screen.dart`) that matches the design shown in flutter_01.png
- **Navigation Flow**: Updated main navigation to show home screen instead of chat directly after login
- **Icon Issues**: Fixed missing icons by using Material Design icons instead of missing SVG assets
- **UI Components**: Added proper top navigation bar with settings, notifications, and profile icons
- **Bottom Navigation**: Implemented bottom navigation with home, search, add button, and profile icons
- **Dark Mode Support**: Added dark mode compatibility throughout the home screen

### Added
- **Home Screen Features**:
  - Welcome message and greeting
  - Daily check-in card with gradient background
  - Quick action cards for Breathe, Meditate, Journal, and Chat
  - Recent activity section
  - Search functionality placeholder
- **Navigation Components**:
  - Top navigation with icon buttons
  - Bottom navigation bar with active state indicators
  - Central add button with prominent styling
- **Responsive Design**: Proper spacing and layout for different screen sizes

### Technical Changes
- **File Structure**: Added `lib/screens/home_screen.dart`
- **Dependencies**: Verified all required dependencies are present in `pubspec.yaml`
- **Imports**: Updated `main.dart` to include and navigate to home screen
- **Theme Integration**: Proper dark/light theme support using existing theme service

### UI Improvements
- **Card Design**: Consistent card styling with shadows and rounded corners
- **Color Scheme**: Used app's primary color (#8FEC95) consistently
- **Typography**: Maintained Satoshi font family throughout
- **Iconography**: Replaced missing SVG icons with Material Design icons
- **Accessibility**: Proper icon button sizing and touch targets

## [Previous] - Version 1.0.0

### Initial Features
- User authentication with Supabase
- Chat functionality with AI models
- Video splash screen
- Settings and profile screens
- Dark/light theme support
- Email verification system
- Onboarding flow
