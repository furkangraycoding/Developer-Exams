# CoderQuest Architecture Guide

## 📐 App Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel (MVVM) architecture pattern for clean separation of concerns and maintainability.

```
┌─────────────────────────────────────┐
│           VIEWS                     │
│  (User Interface Layer)             │
│  - MainMenuView                     │
│  - QuizGameView                     │
│  - ProfileView                      │
│  - etc.                             │
└──────────────┬──────────────────────┘
               │
               │ Observes
               ↓
┌─────────────────────────────────────┐
│        VIEW MODELS                  │
│  (Business Logic Layer)             │
│  - QuizViewModel                    │
│  - ProgressManager                  │
│  - GlobalViewModel                  │
└──────────────┬──────────────────────┘
               │
               │ Uses
               ↓
┌─────────────────────────────────────┐
│          MODELS                     │
│  (Data Layer)                       │
│  - QuizQuestion                     │
│  - Achievement                      │
│  - UserProgress                     │
│  - UserScore                        │
└─────────────────────────────────────┘
```

## 🗂️ File Organization

### Core Files

#### 1. **Developer_ExamsApp.swift**
- **Purpose**: App entry point
- **Key Features**:
  - Initializes app delegate for AdMob
  - Shows splash screen on launch
  - Transitions to main menu
  - Manages global state

#### 2. **Models/**

##### QuizQuestion.swift
```swift
struct QuizQuestion {
    - question: String
    - choices: [String]
    - answer: String
    - point: Int
    - difficulty: DifficultyLevel
    - hint: String?
    - explanation: String?
}
```
- Enhanced question model with difficulty and hints
- Auto-assigns difficulty based on points
- Supports choice shuffling

##### Achievement.swift
```swift
struct Achievement {
    - type: AchievementType
    - title, description
    - isUnlocked: Bool
    - progress tracking
}
```
- 10 predefined achievements
- Progress tracking
- Unlock date recording

##### UserProgress.swift
```swift
struct UserProgress {
    - totalScore, level, XP
    - streaks, accuracy
    - achievements
    - languages played
}
```
- Comprehensive user statistics
- Level and XP system
- Achievement tracking
- Automatic streak updates

##### ProgressManager.swift
```swift
class ProgressManager: ObservableObject {
    - @Published userProgress
    - Save/load from UserDefaults
    - Achievement checking
    - Streak management
}
```
- Singleton pattern
- Real-time progress updates
- Persistent storage

##### QuizViewModel.swift
```swift
class QuizViewModel: ObservableObject {
    - Question loading and management
    - Answer validation
    - Combo system
    - Hint system
    - Game state management
}
```
- Quiz game logic
- Score calculation with multipliers
- Lives system
- Wrong question tracking

#### 3. **Views/**

##### MainMenuView.swift
- Home screen with:
  - Animated background
  - User stats card
  - Language selection grid
  - Quick action buttons
- Entry point after splash

##### QuizGameView.swift
- Main quiz interface with:
  - Difficulty selector
  - Question cards
  - Answer buttons
  - Lives display
  - Combo indicator
  - Hint button
- Handles game flow

##### GameOverView.swift
- Results screen showing:
  - Final score
  - Statistics
  - Level progress
  - Play again option
- Achievement popup overlay

##### ProfileView.swift
- User profile displaying:
  - Level and XP
  - Comprehensive stats grid
  - Languages mastered
  - Achievement count

##### AchievementsView.swift
- Achievement gallery with:
  - Locked/unlocked states
  - Progress bars
  - Unlock dates
  - Beautiful cards

##### LeaderboardView.swift
- High scores with:
  - Language filtering
  - Top 10 per language
  - Crown/medal badges
  - Score display

##### SettingsView.swift
- App settings:
  - Sound toggle
  - Vibration toggle
  - Notifications
  - Reset progress

##### ModernSplashView.swift
- Launch screen with:
  - Animated logo
  - Particle effects
  - Gradient background

#### 4. **Helpers/**

##### ColorExtensions.swift
- Custom color palette
- Gradient presets
- View modifiers for consistent styling
- Card styles
- Button styles

##### ViewExtensions.swift
- Custom transitions (slide, scale, pop)
- Animation presets (smooth, bouncy, gentle)
- Shake effect
- Glow effect
- Shimmer effect
- Pulsing effect
- Loading modifier
- Conditional modifiers

##### HapticManager.swift
- Haptic feedback system
- Impact generators
- Notification feedback
- Selection feedback
- Convenience methods

## 🔄 Data Flow

### Quiz Flow
```
1. User selects language in MainMenuView
   ↓
2. QuizGameView appears
   ↓
3. User selects difficulty
   ↓
4. QuizViewModel loads questions
   ↓
5. User answers questions
   ↓
6. ViewModel validates and updates score
   ↓
7. ProgressManager records stats
   ↓
8. Game over → GameOverView
   ↓
9. Check for new achievements
```

### Progress Tracking Flow
```
1. User completes action (answer, finish game, etc.)
   ↓
2. QuizViewModel calls ProgressManager
   ↓
3. ProgressManager updates UserProgress
   ↓
4. Check achievements
   ↓
5. Save to UserDefaults
   ↓
6. UI updates automatically (@Published)
```

## 💾 Data Persistence

### UserDefaults Keys
- `userProgress` - Main progress data
- `{language}_highScores` - Per-language scores
- `soundEnabled` - Settings
- `vibrationEnabled` - Settings
- `notifications` - Settings

### Data Models Storage
```swift
// Save
let encoder = JSONEncoder()
if let encoded = try? encoder.encode(userProgress) {
    UserDefaults.standard.set(encoded, forKey: "userProgress")
}

// Load
let decoder = JSONDecoder()
if let data = UserDefaults.standard.data(forKey: "userProgress"),
   let progress = try? decoder.decode(UserProgress.self, from: data) {
    self.userProgress = progress
}
```

## 🎯 State Management

### @StateObject
Used for view models that own their data:
```swift
@StateObject private var viewModel = QuizViewModel()
@StateObject private var progressManager = ProgressManager.shared
```

### @ObservedObject
Used when passing view models between views:
```swift
@ObservedObject var viewModel: QuizViewModel
```

### @Published
Properties that trigger UI updates:
```swift
@Published var currentIndex: Int = 0
@Published var score: Int = 0
```

### @State
Local view state:
```swift
@State private var showSettings = false
@State private var selectedLanguage: String?
```

### @Binding
Two-way data binding:
```swift
@Binding var isPresented: Bool
```

## 🎨 UI Components

### Reusable Components

1. **StatBox** - Statistics display card
2. **LanguageCard** - Language selection button
3. **QuickActionButton** - Menu action button
4. **AchievementCard** - Achievement display
5. **LeaderboardRow** - Score row
6. **ProfileStatCard** - Profile stat display
7. **DifficultyButton** - Difficulty selector
8. **AnswerButton** - Quiz answer button
9. **ProgressBar** - Custom progress indicator
10. **ParticlesView** - Animated particles

### Custom Modifiers

```swift
.cardStyle() // Standard card appearance
.primaryButtonStyle() // Gradient button
.secondaryButtonStyle() // Outlined button
.shimmer() // Loading shimmer
.pulsing() // Pulse animation
.glow() // Glow effect
.loading(isLoading) // Loading overlay
```

## 🔧 Key Classes & Protocols

### Singleton Pattern
```swift
class ProgressManager {
    static let shared = ProgressManager()
    private init() {}
}

// Usage
ProgressManager.shared.recordAnswer(...)
```

### Codable Protocol
All data models conform to Codable for easy JSON serialization:
```swift
struct UserProgress: Codable { ... }
struct Achievement: Codable { ... }
```

### Identifiable Protocol
Views requiring unique IDs:
```swift
struct Achievement: Identifiable {
    let id: String
}
```

### ObservableObject Protocol
View models for reactive UI:
```swift
class QuizViewModel: ObservableObject {
    @Published var score: Int = 0
}
```

## 🚀 Performance Optimizations

1. **Lazy Loading**: LazyVGrid and LazyVStack for efficient scrolling
2. **State Management**: Minimal state updates
3. **Animation**: GPU-accelerated Core Animation
4. **Memory**: Weak self in closures to prevent retain cycles
5. **Data Loading**: Async JSON loading on background thread
6. **Caching**: Singleton pattern for shared data

## 🧪 Testing Strategy

### Unit Tests (Recommended)
- QuizViewModel logic
- ProgressManager calculations
- Achievement unlock conditions
- Score calculations
- Streak tracking

### UI Tests (Recommended)
- Navigation flow
- Quiz gameplay
- Achievement unlocking
- Settings persistence
- Leaderboard display

## 📱 iOS Features Used

- SwiftUI framework
- Combine framework
- UserDefaults for persistence
- UIKit integration (haptics)
- Core Animation
- Geometry Reader for responsive layouts
- NavigationView
- Sheet presentations
- Full screen covers
- Alerts

## 🎯 Design Patterns

1. **MVVM** - Separation of concerns
2. **Singleton** - Shared managers
3. **Observer** - Combine publishers
4. **Factory** - View creation
5. **Strategy** - Different difficulty modes
6. **State** - Game state management

## 🔐 Best Practices Followed

✅ SwiftUI lifecycle methods
✅ Property wrappers (@State, @Binding, etc.)
✅ View composition
✅ Reusable components
✅ Consistent naming conventions
✅ Code organization
✅ Memory management
✅ Error handling
✅ Documentation

## 📊 Metrics Tracked

- Total games played
- Questions answered (correct/wrong)
- Accuracy percentage
- Current/longest streaks
- Total score
- Level and XP
- Languages played
- Achievements unlocked
- Hints used
- Perfect rounds
- Fastest completion time

## 🎉 Summary

The architecture is:
- **Scalable**: Easy to add new features
- **Maintainable**: Clean separation of concerns
- **Testable**: Logic separated from UI
- **Performant**: Optimized for smooth 60fps
- **Modern**: Latest SwiftUI practices
- **Professional**: Production-ready code

This architecture provides a solid foundation for future enhancements and ensures the app remains maintainable as it grows! 🚀
