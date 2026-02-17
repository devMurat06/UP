# UP — Focus Timer & Productivity Companion for iOS

#### Video Demo: https://youtu.be/vRSIZtnW4Nw

## Description

**UP** is an iOS productivity app built with SwiftUI that helps you stay focused, take real breaks, and build better daily habits. It goes beyond simple Pomodoro timers by combining forced breaks, session insights, hydration tracking, and a real-time Dynamic Island presence into one clean experience.

The idea came from a constant struggle: long study sessions without breaks, skipped water, and no clear picture of where the time actually went. UP solves all three. When your session ends, a full-screen overlay takes over and *won't let you back in* until you've rested. Your focus data is automatically visualized through heatmaps, activity rings, and a daily focus score — so progress isn't just felt, it's seen. A built-in hydration tracker reminds you to drink water throughout the day. And while you're working, a live countdown runs on the Dynamic Island and Lock Screen so you never need to open the app mid-flow.

## Features

### Focus Timer
- Customizable work & break durations with three quick presets (15 / 25 / 45 min)
- Session tagging with four categories — **Study**, **Work**, **Creative**, **Health**
- Task name input to clarify your intention before each session
- Gradient animated timer ring with pulse effects and category-colored accents
- Ambient soundscapes (rain, forest, café, white noise) during focus sessions

### Forced Breaks
- Non-dismissible full-screen overlay during break periods
- Guided **4-7-8 breathing exercise** with animated visual cues
- Floating ambient particles, motivational quotes, and Lottie animations
- Break countdown displayed prominently so you know when you're free

### Insights & Analytics
- **Focus Score** (0–100) computed daily from sessions, minutes, and streaks
- **Activity Rings** — three concentric rings tracking sessions, minutes, and streak progress
- **Focus Intensity Heatmap** — 28-day color-coded calendar grid (tap any day for details)
- **Weekly Bar Chart** — daily focus minutes for the past 7 days
- **Category Breakdown** — see where your time goes across Study, Work, Creative, and Health

### Achievements
- Six unlockable milestone badges: First Focus, Dedicated, Marathon, On Fire, Centurion, Night Owl
- Glow effects for unlocked badges + confetti animation on unlock

### Hydration Tracker
- Animated water glass with wave animation and real-time fill level
- Quick-add buttons — Small (150ml), Glass (250ml), Bottle (500ml), Large (750ml)
- Today's log with timestamps and weekly water intake chart
- Automatic daily reset with history preservation
- Rotating hydration tips

### Dynamic Island & Lock Screen
- **Live Activity** showing real-time countdown on Dynamic Island and Lock Screen
- Expanded view with task name, category, and gradient progress bar
- Compact and minimal presentations for unobtrusive awareness
- Green theme during breaks, cyan/blue during focus sessions

### Notes
- Searchable note-taking with full-text search across titles, content, and linked tasks
- Category filter chips reusing the existing session categories (Study, Work, Creative, Health)
- Pinned and recent sections with color-tagged note cards
- Note editor with title, rich text area, category picker, linked task, color tags, and pin toggle
- Context menus for pin/unpin, color change, copy text, and delete
- Stats bar showing total notes, word count, and pinned count
- Floating add button with haptic feedback
- Sort by newest or oldest first

### Other
- Full dark mode support
- Customizable notification sounds (Default, Chime, Bell, Soft)
- Streak tracking with daily persistence and best-streak records
- Comprehensive all-time statistics

## Architecture

UP follows the **MVVM** pattern with SwiftUI's reactive state management.

| Layer | Responsibility |
|-------|--------------|
| **Views** | SwiftUI declarative UI organized into tab-based navigation |
| **ViewModel** | `FocusModeTimer` — central `ObservableObject` managing timer, stats, water, notes, and achievements |
| **Persistence** | `@AppStorage` (UserDefaults) for settings, statistics, session history, water logs, and notes |
| **Live Activity** | `ActivityKit` with `LiveActivityManager` singleton for Dynamic Island updates |
| **Audio** | `SoundManager` singleton using `AVFoundation` for ambient sound playback |

## Project Structure

```
UP/
├── FocusApp.swift.swift        # App entry point
├── ContentView.swift           # Tab-based navigation (UP · Insights · Hydration · Notes · Settings)
├── TimerManager.swift          # ViewModel — timer, stats, water, notes, achievements, categories
├── BreakView.swift             # Full-screen forced break overlay
├── BreathingExerciseView.swift # 4-7-8 guided breathing animation
├── SoundManager.swift          # Ambient sound playback manager
├── WaterTrackerView.swift      # Hydration tracking tab
├── NotesTabView.swift          # Note-taking tab with editor
├── InsightsTabView.swift       # Focus score, charts, category breakdown
├── SettingsTabView.swift       # App settings and all-time stats
├── HeatmapView.swift           # 28-day focus intensity calendar
├── ActivityRingView.swift      # Triple concentric progress rings
├── AchievementsView.swift      # Milestone badges with unlock animations
├── UPLiveActivity.swift        # ActivityKit attributes & Live Activity manager
├── LottieView.swift            # UIViewRepresentable Lottie animation wrapper
├── BreakOverlayView.swift      # macOS-specific break overlay
└── UPWidgetExtension/
    └── UPWidgetExtension.swift # Dynamic Island & Lock Screen Live Activity UI
```

## Tech Stack

- **SwiftUI** — declarative UI framework
- **Combine** — reactive data flow
- **ActivityKit** — Dynamic Island & Lock Screen Live Activities
- **AVFoundation** — audio session and ambient sound playback
- **AudioToolbox** — system alert sounds
- **DotLottie** — Lottie animation rendering
- **SF Symbols** — 18+ native system icons throughout the app

## Requirements

- iOS 16.1+ (iOS 16.2+ recommended for Dynamic Island)
- Xcode 15+
- Swift 5.9+

## Getting Started

```bash
git clone https://github.com/your-username/UP.git
cd UP
open UP.xcodeproj
```

1. Open `UP.xcodeproj` in Xcode
2. Select a simulator or connected device
3. Build and run (**⌘R**)
4. Grant notification permissions when prompted

> **Note**: Dynamic Island features require a physical device with Dynamic Island (iPhone 14 Pro or later). The Lock Screen Live Activity works on all devices running iOS 16.1+.

## Design Philosophy

**Helpful constraints over flexibility.** Breaks are forced because research shows people skip voluntary ones. The app respects your focus by keeping interactions minimal — start a session, and everything else happens automatically.

**Progress should be visible.** Activity rings, heatmaps, and the focus score turn abstract effort into concrete visuals. Seeing a 28-day streak or a filled activity ring is more motivating than any notification.

**Stay out of the way.** The Dynamic Island integration means you never need to open the app to check your timer. Focus stays unbroken.

---

**Murat NAR**
*CS50 2026*

N♥️
