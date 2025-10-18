# CoderQuest - Programming Quiz App

## 🎯 Overview
CoderQuest is a comprehensive iOS quiz application designed to help developers learn and master programming languages through interactive quizzes. The app features a modern UI, rich gamification elements, and advanced tracking systems.

## ✨ New Features

### 🎮 Enhanced Gameplay
- **Three Difficulty Levels**
  - **Easy Mode**: 5 hearts, no time limit, 1x points
  - **Medium Mode**: 3 hearts, 30 seconds per question, 1.5x points  
  - **Hard Mode**: 1 heart, 15 seconds per question, 2x points

- **Progress Tracking**
  - Real-time progress bar showing quiz completion
  - Question counter and accuracy display
  - Dynamic timer with visual warnings
  - Heart-based life system

### 🏆 Achievement System
- **15 Unique Achievements** including:
  - First Victory - Complete your first quiz
  - Streak Master - Get 5 correct answers in a row
  - Fire Storm - Get 10 correct answers in a row
  - Legendary Streak - Get 20 correct answers in a row
  - Perfectionist - Complete a quiz without mistakes
  - Speed Demon - Answer 50 questions correctly
  - Lightning Fast - Answer 100 questions correctly
  - Polyglot - Try all programming languages
  - Hard Mode Hero - Complete 10 quizzes in hard mode
  - Centurion - Reach 100 total points
  - Grand Master - Reach 500 total points
  - Legend - Reach 1000 total points
  - Night Owl - Complete a quiz after midnight
  - Early Bird - Complete a quiz before 6 AM
  - Weekend Warrior - Complete 5 quizzes on weekends

- Each achievement grants XP rewards
- Visual badges and progress tracking
- Achievement unlock animations

### 📊 Statistics Dashboard
- **Overall Stats**
  - Player level and XP progress
  - Total games played
  - Overall accuracy percentage
  - Current streak and longest streak
  - Perfect games count
  - Daily goal streak tracking

- **Language-Specific Stats**
  - Individual accuracy per language
  - High scores for each language
  - Total questions answered
  - Time spent on each language
  - Last played date

### 🎨 Modern UI Design
- **Beautiful Gradient Backgrounds**
  - Dynamic color schemes per programming language
  - Animated particle effects
  - Smooth transitions and animations

- **Card-Based Design**
  - Modern language selection cards
  - Glassmorphism effects
  - Smooth hover and press animations

- **Enhanced Typography**
  - Rounded SF Pro fonts
  - Gradient text effects
  - Improved readability

### 🌟 User Experience
- **Improved Onboarding**
  - Animated splash screen with typing effect
  - Modern username input with validation
  - Guest mode option

- **Smart Menu System**
  - Quick action buttons for stats and achievements
  - Difficulty selector before quiz start
  - Language cards showing previous performance

- **Achievement Notifications**
  - Real-time achievement unlock popups
  - XP reward animations
  - Progress celebrations

### 💾 Data Management
- **ProgressManager**
  - Centralized statistics tracking
  - Achievement progress monitoring
  - XP and level calculations
  - Session recording

- **Enhanced Score System**
  - Difficulty-based point multipliers
  - Streak bonuses
  - Perfect game rewards
  - High score tracking per language

## 🛠️ Technical Improvements

### Architecture
- MVVM design pattern
- Singleton managers for global state
- Combine framework for reactive updates
- UserDefaults for data persistence

### New Models
- `Achievement` - Achievement data structure
- `Statistics` - User statistics tracking
- `LanguageStatistics` - Per-language analytics
- `DifficultyLevel` - Enum for game difficulty
- `ProgressManager` - Central progress tracking

### New Views
- `EnhancedQuizView` - Modernized quiz interface
- `StatisticsView` - Comprehensive stats dashboard
- `AchievementsView` - Badge collection display
- `AchievementPopupView` - Real-time achievement notifications
- Enhanced `MenuView` - Redesigned language selection
- Enhanced `SplashScreenView` - Modern onboarding
- Enhanced `UsernameInputView` - Improved login experience

## 🎯 Supported Programming Languages
- Swift
- Java
- JavaScript
- Ruby
- Python
- C#
- Go
- Solidity

Each language includes:
- 100+ questions
- Multiple difficulty levels
- Code-based questions
- Conceptual questions
- Output prediction questions

## 📱 Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- SwiftUI

## 🚀 Getting Started

1. Clone the repository
2. Open `CoderQuest.xcodeproj` in Xcode
3. Build and run on simulator or device
4. Create your username and start learning!

## 🎓 How to Play

1. **Choose Your Language**: Select from 8 programming languages
2. **Select Difficulty**: Pick Easy, Medium, or Hard mode
3. **Answer Questions**: Tap the correct answer before time runs out
4. **Earn Points**: Get bonus points based on difficulty
5. **Track Progress**: View your stats and achievements
6. **Level Up**: Gain XP and unlock achievements

## 🏅 Progression System

### Levels
- Gain XP from answering questions
- Each level requires 100 XP
- Higher difficulty = more XP
- Perfect games = bonus XP

### Streaks
- Build streaks by answering correctly
- Streaks reset on wrong answers
- Track daily streaks for consistency

### Achievements
- Complete specific challenges
- Earn achievement badges
- Gain bonus XP rewards

## 🎨 Design Highlights

- **Color-Coded Languages**: Each language has a unique color theme
- **Smooth Animations**: Spring-based animations throughout
- **Haptic Feedback**: Tactile responses (where available)
- **Dark Theme**: Easy on the eyes with vibrant accents
- **Responsive Layout**: Works on all iOS devices

## 📈 Future Enhancements

- [ ] Multiplayer mode
- [ ] Global leaderboards
- [ ] Daily challenges
- [ ] Custom quiz creation
- [ ] Social sharing
- [ ] More programming languages
- [ ] Code editor integration
- [ ] Offline mode improvements

## 🤝 Contributing

This project showcases modern iOS development practices with SwiftUI. Feel free to explore the codebase and learn from the implementations.

## 📄 License

Copyright © 2025 MagneticMindsApp. All rights reserved.

---

**Built with ❤️ using SwiftUI**

