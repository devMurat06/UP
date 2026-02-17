import SwiftUI
import AudioToolbox

// ========================================
// CONTENT VIEW — Tab-Based Navigation
// ========================================

struct ContentView: View {
    
    @StateObject var focusTimer = FocusModeTimer()
    @StateObject var soundManager = SoundManager.shared
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                
                // Tab 1: Focus
                FocusTabView(manager: focusTimer, soundManager: soundManager)
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Focus")
                    }
                    .tag(0)
                
                // Tab 2: Insights
                InsightsTabView(manager: focusTimer)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Insights")
                    }
                    .tag(1)
                
                // Tab 3: Hydration
                WaterTrackerView(manager: focusTimer)
                    .tabItem {
                        Image(systemName: "drop.fill")
                        Text("Hydration")
                    }
                    .tag(2)
                
                // Tab 4: Notes
                NotesTabView(manager: focusTimer)
                    .tabItem {
                        Image(systemName: "note.text")
                        Text("Notes")
                    }
                    .tag(3)
                
                // Tab 5: Settings
                SettingsTabView(manager: focusTimer)
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag(4)
            }
            .tint(.blue)
            
            // achievement unlock overlay
            if let achievement = focusTimer.newlyUnlockedAchievement {
                AchievementUnlockOverlay(achievement: achievement) {
                    focusTimer.dismissAchievementAlert()
                }
                .zIndex(100)
                .transition(.opacity)
            }
        }
        .preferredColorScheme(focusTimer.darkModeEnabled ? .dark : .light)
        .fullScreenCover(isPresented: $focusTimer.isOnBreak) {
            BreakView(manager: focusTimer)
        }
    }
}

// ========================================
// FOCUS TAB
// ========================================

struct FocusTabView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @ObservedObject var soundManager: SoundManager
    
    // gradient animation for timer ring
    @State private var gradientRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            GeometryReader { screenSize in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        
                        // streak badge
                        if manager.currentStreak > 0 {
                            streakBadge
                        }
                        
                        // task input
                        taskInput
                        
                        // category selector
                        categorySelector
                        
                        // timer circle
                        timerCircle(size: screenSize)
                        
                        // quick presets
                        quickPresets
                        
                        // today's mini stats
                        todayStats
                        
                        // start/stop button
                        actionButton
                    }
                    .padding()
                }
            }
            .navigationTitle("UP")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // ========================================
    // STREAK BADGE
    // ========================================
    
    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .symbolEffect(.bounce, value: manager.currentStreak)
            Text("\(manager.currentStreak)-day streak")
                .font(.subheadline)
                .fontWeight(.semibold)
            if manager.currentStreak == manager.bestStreak && manager.bestStreak > 1 {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.12))
        )
    }
    
    // ========================================
    // TASK INPUT
    // ========================================
    
    private var taskInput: some View {
        HStack(spacing: 10) {
            Image(systemName: "pencil.line")
                .foregroundStyle(.blue)
            
            TextField("What are you working on?", text: $manager.currentTaskName)
                .textFieldStyle(.plain)
            
            if !manager.currentTaskName.isEmpty {
                Button {
                    manager.currentTaskName = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
    
    // ========================================
    // CATEGORY SELECTOR
    // ========================================
    
    private var categorySelector: some View {
        HStack(spacing: 8) {
            ForEach(SessionCategory.allCases, id: \.self) { category in
                let isSelected = manager.selectedCategory == category
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        manager.selectedCategory = category
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: category.icon)
                            .font(.caption)
                        Text(category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isSelected ? category.color.opacity(0.2) : Color.gray.opacity(0.08))
                    )
                    .foregroundStyle(isSelected ? category.color : .secondary)
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? category.color.opacity(0.4) : .clear, lineWidth: 1.5)
                    )
                }
            }
        }
    }
    
    // ========================================
    // TIMER CIRCLE
    // ========================================
    
    private func timerCircle(size: GeometryProxy) -> some View {
        let circleSize = min(size.size.width * 0.6, 260)
        
        return ZStack {
            // outer glow
            if manager.isTimerRunning {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [manager.selectedCategory.color.opacity(0.15), .clear],
                            center: .center,
                            startRadius: circleSize * 0.35,
                            endRadius: circleSize * 0.6
                        )
                    )
                    .frame(width: circleSize + 40, height: circleSize + 40)
                    .scaleEffect(pulseScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            pulseScale = 1.08
                        }
                    }
            }
            
            // background ring
            Circle()
                .stroke(lineWidth: 16)
                .opacity(0.1)
                .foregroundStyle(manager.selectedCategory.color)
            
            // progress ring with gradient
            if manager.isTimerRunning {
                Circle()
                    .trim(from: 0.0, to: CGFloat(manager.timeRemaining / (manager.workMinutes * 60)))
                    .stroke(
                        AngularGradient(
                            colors: [
                                manager.selectedCategory.color,
                                manager.selectedCategory.color.opacity(0.6),
                                manager.selectedCategory.color.opacity(0.3),
                                manager.selectedCategory.color
                            ],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: manager.timeRemaining)
            }
            
            // center content
            VStack(spacing: 6) {
                if manager.isTimerRunning {
                    Image(systemName: manager.selectedCategory.icon)
                        .font(.title3)
                        .foregroundStyle(manager.selectedCategory.color.opacity(0.6))
                    
                    Text(formatTime(manager.timeRemaining))
                        .font(.system(size: circleSize * 0.18, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                    
                    if !manager.currentTaskName.isEmpty {
                        Text(manager.currentTaskName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                } else {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: circleSize * 0.2))
                        .foregroundStyle(manager.selectedCategory.color.opacity(0.3))
                    Text("Ready")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(manager.selectedCategory.color)
                }
            }
        }
        .frame(width: circleSize, height: circleSize)
        .padding(.vertical, 8)
    }
    
    // ========================================
    // QUICK PRESETS
    // ========================================
    
    private var quickPresets: some View {
        HStack(spacing: 10) {
            presetButton(title: "Short", minutes: 15, icon: "bolt.fill", color: .green)
            presetButton(title: "Classic", minutes: 25, icon: "timer", color: .blue)
            presetButton(title: "Deep", minutes: 45, icon: "brain.head.profile", color: .purple)
        }
    }
    
    private func presetButton(title: String, minutes: Int, icon: String, color: Color) -> some View {
        let isSelected = Int(manager.workMinutes) == minutes
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                manager.workMinutes = Double(minutes)
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.title3)
                    .symbolEffect(.bounce, value: isSelected)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("\(minutes) min")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color.opacity(0.2) : color.opacity(0.08))
            .foregroundStyle(isSelected ? color : .secondary)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? color.opacity(0.4) : .clear, lineWidth: 1.5)
            )
        }
    }
    
    // ========================================
    // TODAY STATS
    // ========================================
    
    private var todayStats: some View {
        HStack(spacing: 0) {
            statItem(icon: "checkmark.circle.fill", value: "\(manager.todayCompleted)", label: "Sessions", color: .green)
            Divider().frame(height: 36)
            statItem(icon: "clock.fill", value: "\(manager.todayFocusMinutes)", label: "Minutes", color: .blue)
            Divider().frame(height: 36)
            statItem(icon: "flame.fill", value: "\(manager.currentStreak)", label: "Streak", color: .orange)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // ========================================
    // ACTION BUTTON
    // ========================================
    
    private var actionButton: some View {
        Button {
            if manager.isTimerRunning {
                manager.stopTimer()
            } else {
                manager.startSession()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: manager.isTimerRunning ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title3)
                Text(manager.isTimerRunning ? "Stop Session" : "Start Focus")
                    .fontWeight(.bold)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: manager.isTimerRunning
                        ? [.red.opacity(0.8), .red]
                        : [manager.selectedCategory.color.opacity(0.8), manager.selectedCategory.color],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: (manager.isTimerRunning ? Color.red : manager.selectedCategory.color).opacity(0.3),
                radius: 10,
                y: 5
            )
        }
        .padding(.bottom, 20)
    }
    
    // ========================================
    // HELPERS
    // ========================================
    
    func formatTime(_ totalSeconds: Double) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// ========================================
// PREVIEW
// ========================================

#Preview {
    ContentView()
}
