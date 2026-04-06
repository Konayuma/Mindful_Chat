# Mindful Chat - Documentation

## Overview

Mindful Chat is a comprehensive mental health application designed to provide users with tools for meditation, journaling, mood tracking, and AI-powered mental health support. The app features a modern, intuitive interface with both light and dark theme support.

## Features

### Core Functionality
- **User Authentication**: Secure signup/signin with email verification
- **AI Chat**: Mental health companion with multiple AI models
- **Home Dashboard**: Central hub for wellness activities
- **Meditation & Breathing**: Guided exercises for mental wellness
- **Journaling**: Personal reflection and mood tracking
- **Theme System**: Light/dark mode with user preferences

### Screen Breakdown

#### 1. Welcome Screen (`welcome_screen.dart`)
- App introduction with brain illustration
- Sign in and create account options
- Privacy policy and terms of service links

#### 2. Home Screen (`home_screen.dart`)
- **Top Navigation**: Settings, notifications, and profile icons
- **Welcome Section**: Personalized greeting and mood check-in
- **Daily Check-in Card**: Gradient-styled wellness prompt
- **Quick Actions**: 
  - Breathe (breathing exercises)
  - Meditate (meditation sessions)
  - Journal (personal reflection)
  - Chat (AI companion)
- **Recent Activity**: User engagement history
- **Bottom Navigation**: Home, Search, Add, Resources, Profile

#### 3. Chat Screen (`chat_screen.dart`)
- AI-powered mental health conversations
- Multiple AI model selection
- Conversation history and search
- Message persistence with Supabase
- Copy and share functionality

#### 4. Settings Screen (`settings_screen.dart`)
- Theme preferences (light/dark mode)
- Account management
- App preferences and configurations

#### 5. Authentication Screens
- **Sign In Screen**: User login with credentials
- **Sign Up Screen**: New user registration
- **Email Verification**: OTP-based verification system
- **Password Creation**: Secure password setup

## Technical Architecture

### Backend Services
- **Supabase**: Authentication, database, and real-time features
- **LLM Service**: AI model integration for chat functionality
- **API Service**: Health checks and external API communication

### State Management
- **Theme Service**: Centralized theme management
- **Authentication Service**: User session management
- **Database Service**: Conversation and message persistence

### UI Components
- **Material Design 3**: Modern design system implementation
- **Custom Widgets**: Reusable components for consistent UI
- **Responsive Design**: Adaptive layouts for different screen sizes

## Dependencies

### Core Flutter
- `flutter`: Flutter SDK
- `cupertino_icons`: iOS-style icons
- `flutter_svg`: SVG image support

### Backend & Services
- `supabase_flutter`: Supabase integration
- `http`: HTTP requests
- `flutter_dotenv`: Environment variable management

### UI & UX
- `fluttertoast`: Toast notifications
- `video_player`: Video playback for splash screen
- `shared_preferences`: Local data persistence

## File Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── screens/                  # UI screens
│   ├── home_screen.dart      # Main dashboard (NEW)
│   ├── chat_screen.dart      # AI chat interface
│   ├── welcome_screen.dart   # App introduction
│   ├── settings_screen.dart  # User settings
│   ├── signin_screen.dart    # User login
│   ├── signup_screen.dart    # User registration
│   ├── email_verification_screen.dart
│   ├── video_splash_screen.dart
│   └── ...                   # Additional screens
├── services/                 # Business logic
│   ├── supabase_service.dart
│   ├── supabase_auth_service.dart
│   ├── supabase_database_service.dart
│   ├── llm_service.dart
│   ├── theme_service.dart
│   └── ...                   # Additional services
└── assets/                   # Static assets
    └── images/               # Images and SVGs
```

## Theme System

### Light Theme
- **Primary Color**: #8FEC95 (Green accent)
- **Background**: #FFFFFF (White)
- **Surface**: #F3F3F3 (Light gray)
- **Text**: #000000 (Black)

### Dark Theme
- **Primary Color**: #8FEC95 (Green accent)
- **Background**: #121212 (Dark gray)
- **Surface**: #1E1E1E (Medium gray)
- **Text**: #FFFFFF (White)

## Navigation Flow

```
Splash Screen → Welcome Screen → Authentication → Home Screen
                                                ↓
                                            Chat Screen
                                                ↓
                                            Settings Screen
```

## Recent Updates (v1.0.1)

### Home Screen Implementation
- Complete redesign to match modern wellness app aesthetics
- Added comprehensive navigation system
- Integrated quick action buttons for core features
- Implemented responsive card-based layout

### Icon System
- Replaced missing SVG assets with Material Design icons
- Consistent icon sizing and color theming
- Proper touch targets for accessibility

### User Experience Improvements
- Streamlined navigation flow
- Enhanced visual hierarchy
- Improved accessibility features
- Better error handling and user feedback

## Development Guidelines

### Code Style
- Follow Flutter/Dart conventions
- Use descriptive variable and function names
- Implement proper error handling
- Add comprehensive comments

### UI/UX Principles
- Maintain consistency across screens
- Use app's color scheme consistently
- Implement proper spacing and typography
- Ensure accessibility compliance

### Testing
- Test on multiple screen sizes
- Verify dark/light theme functionality
- Check authentication flows
- Validate API integrations

## Future Enhancements

### Planned Features
- [ ] Advanced mood tracking with analytics
- [ ] Guided meditation audio content
- [ ] Community support features
- [ ] Integration with wearable devices
- [ ] Progress tracking and insights

### Technical Improvements
- [ ] Enhanced offline capabilities
- [ ] Performance optimizations
- [ ] Advanced security features
- [ ] Multi-language support

## Support and Maintenance

### Regular Updates
- Security patches and dependency updates
- Feature enhancements based on user feedback
- Performance optimizations
- Bug fixes and stability improvements

### Monitoring
- Crash reporting and analytics
- User feedback collection
- Performance metrics tracking
- API health monitoring

---

**Last Updated**: 2025-04-07  
**Version**: 1.0.1  
**Maintainer**: Mindful Chat Development Team
