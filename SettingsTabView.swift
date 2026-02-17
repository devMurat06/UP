import SwiftUI
import AudioToolbox

// ========================================
// SETTINGS TAB
// ========================================
// Clean grouped-list layout for all app settings

struct SettingsTabView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @StateObject var soundManager = SoundManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // duration settings
                    durationSection
                    
                    // daily goals
                    goalsSection
                    
                    // alert sound picker
                    alertSoundSection
                    
                    // focus sound picker
                    focusSoundSection
                    
                    // appearance
                    appearanceSection
                    
                    // stats overview
                    allTimeStats
                }
                .padding()
            }
            .navigationTitle("Settings")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // ========================================
    // DURATION
    // ========================================
    
    private var durationSection: some View {
        VStack(spacing: 18) {
            // section header
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text("Timer Duration")
                    .font(.headline)
                Spacer()
            }
            
            // work duration
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "laptopcomputer")
                        .foregroundStyle(.blue)
                    Text("Work")
                    Spacer()
                    Text("\(Int(manager.workMinutes)) min")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .monospacedDigit()
                }
                .font(.subheadline)
                
                Slider(value: $manager.workMinutes, in: 1...120, step: 1)
                    .tint(.blue)
            }
            
            Divider()
            
            // break duration
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(.green)
                    Text("Break")
                    Spacer()
                    Text("\(Int(manager.breakMinutes)) min")
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                        .monospacedDigit()
                }
                .font(.subheadline)
                
                Slider(value: $manager.breakMinutes, in: 1...30, step: 1)
                    .tint(.green)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // ========================================
    // DAILY GOALS
    // ========================================
    
    private var goalsSection: some View {
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text("Daily Goals")
                    .font(.headline)
                Spacer()
            }
            
            // session goal
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Session Goal")
                    .font(.subheadline)
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        if manager.dailySessionGoal > 1 {
                            manager.dailySessionGoal -= 1
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("\(manager.dailySessionGoal)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .frame(width: 30)
                    
                    Button {
                        if manager.dailySessionGoal < 20 {
                            manager.dailySessionGoal += 1
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Divider()
            
            // minute goal
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.blue)
                Text("Minute Goal")
                    .font(.subheadline)
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        if manager.dailyMinuteGoal > 10 {
                            manager.dailyMinuteGoal -= 10
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("\(manager.dailyMinuteGoal)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .frame(width: 44)
                    
                    Button {
                        if manager.dailyMinuteGoal < 480 {
                            manager.dailyMinuteGoal += 10
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // ========================================
    // ALERT SOUND
    // ========================================
    
    private var alertSoundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "bell.badge.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
                Text("Alert Sound")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(FocusModeTimer.AlertSound.allCases, id: \.self) { sound in
                    let isSelected = manager.alertSoundChoice == sound.rawValue
                    
                    Button {
                        manager.alertSoundChoice = sound.rawValue
                        AudioServicesPlaySystemSound(sound.soundID)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: sound.icon)
                                .font(.body)
                            Text(sound.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? Color.red.opacity(0.15) : Color.gray.opacity(0.08))
                        .foregroundStyle(isSelected ? .red : .secondary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.red.opacity(0.5) : .clear, lineWidth: 1.5)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // ========================================
    // FOCUS SOUND
    // ========================================
    
    private var focusSoundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "headphones")
                    .font(.title3)
                    .foregroundStyle(.indigo)
                Text("Focus Sound")
                    .font(.headline)
                Spacer()
                if soundManager.silentModeActive {
                    Image(systemName: "speaker.slash.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 8) {
                ForEach(AmbientSound.allCases, id: \.self) { ambientSound in
                    let isSelected = soundManager.selectedSound == ambientSound
                    
                    Button {
                        soundManager.selectSound(ambientSound)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: ambientSound.icon)
                                .font(.body)
                            Text(ambientSound.rawValue)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? Color.indigo.opacity(0.15) : Color.gray.opacity(0.08))
                        .foregroundStyle(isSelected ? .indigo : .secondary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.indigo.opacity(0.5) : .clear, lineWidth: 1.5)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // ========================================
    // APPEARANCE
    // ========================================
    
    private var appearanceSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "paintpalette.fill")
                    .font(.title3)
                    .foregroundStyle(.purple)
                Text("Appearance")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Image(systemName: manager.darkModeEnabled ? "moon.fill" : "sun.max.fill")
                    .foregroundStyle(manager.darkModeEnabled ? .indigo : .orange)
                Text("Dark Mode")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $manager.darkModeEnabled)
                    .labelsHidden()
                    .tint(.indigo)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // ========================================
    // ALL-TIME STATS
    // ========================================
    
    private var allTimeStats: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundStyle(.green)
                Text("All Time")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 0) {
                statItem(icon: "checkmark.seal.fill", value: "\(manager.totalCompleted)", label: "Sessions", color: .green)
                Divider().frame(height: 40)
                statItem(icon: "hourglass", value: "\(manager.totalFocusTime)", label: "Minutes", color: .blue)
                Divider().frame(height: 40)
                statItem(icon: "flame.fill", value: "\(manager.bestStreak)", label: "Best Streak", color: .orange)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
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
}
