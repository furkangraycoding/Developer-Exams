# CoderQuest - Quick Start Guide

## 🚀 Getting Started

### Build & Run
1. Open `CoderQuest.xcodeproj` in Xcode
2. Select your target device/simulator
3. Press `Cmd + R` to build and run
4. App will launch with splash screen

---

## 🎮 How to Play

### First Launch
1. **Splash Screen** (2-3 seconds)
   - Watch the animated logo
   - See "CoderQuest" title appear

2. **Username Input**
   - Enter your username (max 16 characters)
   - Or click "Continue as Guest" for random name
   - Click "Start Learning"

3. **Main Menu**
   - See your level and XP at top
   - Three quick action buttons:
     - **Stats** - View your statistics
     - **Achievements** - See unlocked badges
     - **Streak** - Current correct streak
   - Select a programming language to start

### Playing a Quiz

1. **Question Display**
   - Watch animations load:
     - Rotating star badge
     - Pulsing status dots
     - Question card slides in
     - Answer buttons stagger in
   - Read the question carefully
   - Note the points value at top right

2. **Select Answer**
   - Tap A, B, C, or D
   - Watch button animate with:
     - Rotating outer ring
     - Shimmer effect
     - Glow layers
   - See feedback (Correct! / Try Again!)

3. **Heart System**
   - Start with 5 hearts (❤️❤️❤️❤️❤️)
   - Lose 1 heart per wrong answer
   - Game ends at 0 hearts

4. **Game Over**
   - See your final score
   - View statistics (questions, accuracy)
   - Watch for achievement popups! 🎉
   - Choose:
     - **Restart** - Play again
     - **Continue** - Watch ad for more hearts

---

## 🏆 Achievement System

### How Achievements Work

**During Game:**
- Play normally, answer questions
- System tracks your progress automatically
- NO popups during gameplay

**On Game Over:**
1. Console logs show what's happening
2. Check for newly unlocked achievements
3. If new achievements → Popup appears
4. Popup shows for 4.5 seconds
5. Auto-hides and clears
6. Next game starts fresh

**Console Output Example:**
```
💀 Game Over detected
🗑️ Clearing 0 recent achievements
📊 Recording game session...
🎉 Unlocking achievement: First Victory
✅ Achievement unlocked, total recent: 1
🎊 Showing 1 NEW achievement(s)
🎯 Displaying 1 achievement popup(s)
⏰ Auto-hiding achievement popup
🗑️ Clearing 1 recent achievements
```

### Checking Achievements

**From Main Menu:**
1. Tap "Achievements" button
2. See grid of all achievements
3. **Unlocked** = Colorful with badge
4. **Locked** = Greyed out with progress
5. Tap any achievement for details

**Achievement Stats:**
- Top right shows "X/15" unlocked count
- Circular progress indicator
- Each has progress bar if locked

---

## 📊 Statistics Dashboard

**Access:**
- Tap "Stats" from main menu

**What You See:**

1. **Level Card**
   - Current level
   - Total XP
   - Progress bar to next level
   - XP needed displayed

2. **Quick Stats Grid**
   - Games Played
   - Overall Accuracy
   - Current Streak
   - Perfect Games

3. **Performance Details**
   - Total questions answered
   - Correct answers (green)
   - Wrong answers (red)
   - Longest streak
   - Daily goal streak

4. **Language Progress**
   - Card for each played language
   - Shows: points, accuracy, questions
   - Sorted by total points

---

## 🎨 Understanding the UI

### Question Card Elements

**Top Section:**
- **Points Badge** (top right)
  - Rotating star icon ⭐
  - Floating up/down
  - Pulsing glow
  - Shows point value

**Middle Section:**
- **Status Dots** (● ● ●) - Pulse animation
- **"QUESTION" Label** with lightning bolt
- **Animated Divider** - Expands left to right
- **Brain Icon** - Rotating ring, triple glow
- **Question Text** - Center aligned

**Bottom Section:**
- **Answer Buttons (A/B/C/D)**
  - Letter badge with animations
  - Answer text
  - When selected:
    - Rotating outer ring
    - Shimmer sweep effect
    - Triple glow layers
    - Checkmark appears

### Active Animations

**You'll See:**
1. Star rotation (continuous, 8s)
2. Badge floating (3s cycle)
3. Glow pulsing (2s cycle)
4. Status dots pulsing (1.2s each)
5. Divider expanding (0.8s on entry)
6. Ring rotation (4s continuous)
7. Icon pulse (2s cycle)
8. Shimmer sweep (2s when selected)
9. Button entry stagger (0.1s delay each)

All running at **60 FPS** smoothly!

---

## 🐛 Debugging Achievements

### Enable Console

**In Xcode:**
1. Run app in debug mode
2. Open Console (bottom panel)
3. Watch for emoji logs 🎮💀📊🎉

**What to Look For:**

✅ **Good Logs:**
```
🎮 Setting up new game
✅ Game setup complete
💀 Game Over detected
🎉 Unlocking achievement: First Victory
🎊 Showing 1 NEW achievement(s)
🗑️ Clearing achievements
```

❌ **Problem Indicators:**
```
⚠️ Achievement already unlocked, skipping
(Means it tried to unlock again - guard caught it!)
```

### Testing Achievement Fix

**Test Case 1: First Game**
```
1. Start fresh app
2. Play and lose
3. Should see "First Victory" popup
4. Check console - should log unlock
```

**Test Case 2: Second Game**
```
1. Restart game immediately
2. Play and lose
3. Should see NO popup (already unlocked)
4. Check console - should log "already unlocked, skipping"
```

**Test Case 3: Multiple Sessions**
```
1. Close app completely
2. Reopen and play
3. Should still see NO "First Victory" popup
4. Only new achievements should show
```

---

## 🎯 Pro Tips

### Maximize XP Gain
- Perfect games give +50 XP bonus
- Build streaks for streak achievements
- Try all 8 languages for Polyglot achievement
- Play on weekends for Weekend Warrior

### UI Appreciation
- Take time to watch the entry animations
- Notice the shimmer effect on selected answers
- Observe the rotating star and rings
- Watch the pulsing glows and floating badge

### Language Strategy
1. Start with Swift (familiar if you know iOS)
2. Try Python (generally well-known)
3. Attempt all 8 for the Polyglot achievement
4. Track which languages you're best at in Stats

---

## 🛠️ Troubleshooting

### Issue: Animations Lag
**Fix:** Test on physical device, not simulator
- Simulator can be slower
- Real device shows true 60 FPS

### Issue: Achievement Shows Twice
**Check Console:**
- Should see "already unlocked, skipping"
- If not, something bypassed the guard
- Report what's happening before unlock

### Issue: Stats Not Saving
**Try:**
1. Complete a full game (don't force quit)
2. Let game over screen show completely
3. Check Statistics view to verify

### Issue: Questions Not Loading
**Check:**
1. JSON files exist in Contents folder
2. Language name matches exactly
3. Console for "JSON file not found" error

---

## 📱 Best Experience

### Recommended Settings
- **Orientation:** Portrait
- **iOS Version:** 16.0+ for best performance
- **Device:** iPhone 12 or newer
- **Storage:** 50MB free space
- **Network:** Not required (offline capable)

### Accessibility
- Large touch targets (48px+)
- High contrast text
- Clear visual feedback
- Readable font sizes
- Intuitive icons

---

## 🎉 Enjoy!

You're all set! The app features:
- ✨ 10+ simultaneous animations
- 🏆 15 unique achievements
- 📊 Complete statistics tracking
- 🎨 Revolutionary UI design
- 🔥 Bulletproof achievement system

**Have fun learning programming!** 🚀

---

## 📞 Support

For issues or questions:
1. Check console logs for debugging
2. Review COMPLETE_PROJECT_STATUS.md
3. See FINAL_ACHIEVEMENT_FIX.md for technical details

**Version**: 2.0.0  
**Status**: Production Ready ✅
