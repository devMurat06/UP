import Foundation
import SwiftUI
import Combine
import AudioToolbox
import Intents

// ========================================
// SESSION CATEGORY
// ========================================

enum SessionCategory: String, CaseIterable, Codable {
    case study = "Study"
    case work = "Work"
    case creative = "Creative"
    case health = "Health"
    
    var icon: String {
        switch self {
        case .study: return "book.fill"
        case .work: return "briefcase.fill"
        case .creative: return "paintbrush.fill"
        case .health: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .study: return .blue
        case .work: return .orange
        case .creative: return .purple
        case .health: return .pink
        }
    }
}

// ========================================
// ACHIEVEMENT SYSTEM
// ========================================

enum Achievement: String, CaseIterable, Codable, Identifiable {
    case firstSession = "First Focus"
    case tenSessions = "Dedicated"
    case marathon = "Marathon"
    case weekStreak = "On Fire"
    case hundredMinutes = "Centurion"
    case nightOwl = "Night Owl"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .firstSession: return "star.fill"
        case .tenSessions: return "trophy.fill"
        case .marathon: return "bolt.shield.fill"
        case .weekStreak: return "flame.fill"
        case .hundredMinutes: return "crown.fill"
        case .nightOwl: return "moon.stars.fill"
        }
    }
    
    var description: String {
        switch self {
        case .firstSession: return "Complete your first session"
        case .tenSessions: return "Complete 10 sessions"
        case .marathon: return "Focus for 60+ minutes in one session"
        case .weekStreak: return "Maintain a 7-day streak"
        case .hundredMinutes: return "Reach 100 total focus minutes"
        case .nightOwl: return "Complete a session after 10 PM"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .firstSession: return [.yellow, .orange]
        case .tenSessions: return [.orange, .red]
        case .marathon: return [.blue, .purple]
        case .weekStreak: return [.red, .pink]
        case .hundredMinutes: return [.purple, .indigo]
        case .nightOwl: return [.indigo, .blue]
        }
    }
}

// ========================================
// SESSION HISTORY ENTRY
// ========================================

struct SessionEntry: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let minutes: Int
    let category: SessionCategory
    let taskName: String
}

// ========================================
// WATER LOG ENTRY
// ========================================

struct WaterLogEntry: Codable, Identifiable {
    var id = UUID()
    let time: Date
    let ml: Int
}

// ========================================
// NOTE ENTRY
// ========================================

struct NoteEntry: Codable, Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var category: SessionCategory
    var date: Date
    var isPinned: Bool = false
    var linkedTask: String = ""
    var colorTag: String = "blue"
}

// ========================================
// FOCUS MODE TIMER (ViewModel)
// ========================================

class FocusModeTimer: ObservableObject {
    
    // ========================================
    // USER SETTINGS
    // ========================================
    
    @Published var workMinutes: Double = 25
    @Published var breakMinutes: Double = 5
    @Published var currentTaskName: String = ""
    @Published var selectedCategory: SessionCategory = .study
    
    // daily session goal (for activity ring)
    @AppStorage("dailySessionGoal") var dailySessionGoal: Int = 4
    @AppStorage("dailyMinuteGoal") var dailyMinuteGoal: Int = 120
    
    @AppStorage("selectedAlertSound") var alertSoundChoice: String = "Default"
    @AppStorage("isDarkModeOn") var darkModeEnabled: Bool = false
    
    // ========================================
    // TIMER STATE
    // ========================================
    
    @Published var timeRemaining: Double = 0
    @Published var isOnBreak: Bool = false
    @Published var isTimerRunning: Bool = false
    @Published var motivationalQuote: String = "Take a breather, you earned it!"
    
    // ========================================
    // STATISTICS (persisted)
    // ========================================
    
    @AppStorage("totalSessionsCompleted") var totalCompleted: Int = 0
    @AppStorage("totalFocusMinutes") var totalFocusTime: Int = 0
    @AppStorage("todaySessionCount") var todayCompleted: Int = 0
    @AppStorage("todayFocusMinutes") var todayFocusMinutes: Int = 0
    @AppStorage("lastSessionDate") var lastDate: String = ""
    
    // streak
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("bestStreak") var bestStreak: Int = 0
    @AppStorage("lastStreakDate") var lastStreakDay: String = ""
    
    // achievements (stored as JSON string)
    @AppStorage("unlockedAchievements") var unlockedAchievementsData: String = "[]"
    
    // session history (stored as JSON string, last 28 days)
    @AppStorage("sessionHistory") var sessionHistoryData: String = "[]"
    
    // ========================================
    // WATER TRACKING (persisted)
    // ========================================
    
    @AppStorage("waterIntakeML") var waterIntakeML: Int = 0
    @AppStorage("waterGoalML") var waterGoalML: Int = 2000
    @AppStorage("waterLogData") var waterLogData: String = "[]"
    @AppStorage("waterDate") var waterDate: String = ""
    @AppStorage("weeklyWaterHistoryData") var weeklyWaterHistoryData: String = "[]"
    
    // ========================================
    // NOTES (persisted)
    // ========================================
    
    @AppStorage("notesData") var notesData: String = "[]"
    
    // newly unlocked achievement (for animation)
    @Published var newlyUnlockedAchievement: Achievement? = nil
    
    // ========================================
    // PRIVATE
    // ========================================
    
    private var focusTimer: Timer?
    private var sessionStartTime: Date?
    
    private let quotes = [
        "Rest your eyes for a bit",
        "Grab a glass of water",
        "Relax your shoulders",
        "Look out the window",
        "Take a deep breath...",
        "Stand up and stretch",
        "Fix your posture!",
        "You're doing great"
    ]
    
    // notification sound options
    enum AlertSound: String, CaseIterable {
        case `default` = "Default"
        case chime = "Chime"
        case bell = "Bell"
        case soft = "Soft"
        
        var soundID: SystemSoundID {
            switch self {
            case .default: return 1005
            case .chime: return 1025
            case .bell: return 1013
            case .soft: return 1001
            }
        }
        
        var icon: String {
            switch self {
            case .default: return "bell.fill"
            case .chime: return "bell.and.waves.left.and.right"
            case .bell: return "bell.circle.fill"
            case .soft: return "bell.slash.fill"
            }
        }
    }
    
    // ========================================
    // COMPUTED PROPERTIES
    // ========================================
    
    var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var unlockedAchievements: Set<String> {
        get {
            let data = Data(unlockedAchievementsData.utf8)
            return (try? JSONDecoder().decode(Set<String>.self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                unlockedAchievementsData = str
            }
        }
    }
    
    var sessionHistory: [SessionEntry] {
        get {
            let data = Data(sessionHistoryData.utf8)
            return (try? JSONDecoder().decode([SessionEntry].self, from: data)) ?? []
        }
        set {
            // keep only last 28 days
            let cutoff = Calendar.current.date(byAdding: .day, value: -28, to: Date()) ?? Date()
            let filtered = newValue.filter { $0.date >= cutoff }
            if let data = try? JSONEncoder().encode(filtered),
               let str = String(data: data, encoding: .utf8) {
                sessionHistoryData = str
            }
        }
    }
    
    /// Focus Score (0–100) based on today's performance
    var focusScore: Int {
        let sessionScore = min(Double(todayCompleted) / max(Double(dailySessionGoal), 1), 1.0) * 40
        let minuteScore = min(Double(todayFocusMinutes) / max(Double(dailyMinuteGoal), 1), 1.0) * 40
        let streakScore = min(Double(currentStreak) / 7.0, 1.0) * 20
        return min(Int(sessionScore + minuteScore + streakScore), 100)
    }
    
    /// Smart insight message based on score
    var focusInsight: String {
        switch focusScore {
        case 0..<20: return "Start a session to build momentum!"
        case 20..<40: return "Good start — keep the focus going."
        case 40..<60: return "Solid progress today. Stay consistent!"
        case 60..<80: return "Great work! You're in the zone."
        case 80...100: return "Outstanding focus day! 🏆"
        default: return "Keep going!"
        }
    }
    
    /// Daily focus minutes grouped by day for the past 7 days
    var weeklyFocusData: [(day: String, minutes: Int)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        var result: [(day: String, minutes: Int)] = []
        for offset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let dayStr = formatter.string(from: date)
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let dayMinutes = sessionHistory
                .filter { $0.date >= startOfDay && $0.date < endOfDay }
                .reduce(0) { $0 + $1.minutes }
            
            result.append((day: dayStr, minutes: dayMinutes))
        }
        return result
    }
    
    /// Daily focus data for the heatmap (past 28 days)
    var heatmapData: [Date: Int] {
        let calendar = Calendar.current
        var map: [Date: Int] = [:]
        for entry in sessionHistory {
            let day = calendar.startOfDay(for: entry.date)
            map[day, default: 0] += entry.minutes
        }
        return map
    }
    
    /// Category breakdown for insights
    var categoryBreakdown: [(category: SessionCategory, minutes: Int)] {
        var totals: [SessionCategory: Int] = [:]
        for entry in sessionHistory {
            totals[entry.category, default: 0] += entry.minutes
        }
        return SessionCategory.allCases.map { cat in
            (category: cat, minutes: totals[cat] ?? 0)
        }
    }
    
    // ========================================
    // WATER TRACKING COMPUTED PROPERTIES
    // ========================================
    
    var waterLog: [WaterLogEntry] {
        get {
            let data = Data(waterLogData.utf8)
            return (try? JSONDecoder().decode([WaterLogEntry].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                waterLogData = str
            }
        }
    }
    
    struct DailyWaterRecord: Codable {
        let date: String
        let ml: Int
    }
    
    var weeklyWaterHistory: [DailyWaterRecord] {
        get {
            let data = Data(weeklyWaterHistoryData.utf8)
            return (try? JSONDecoder().decode([DailyWaterRecord].self, from: data)) ?? []
        }
        set {
            // keep last 7 days
            let recent = Array(newValue.suffix(7))
            if let data = try? JSONEncoder().encode(recent),
               let str = String(data: data, encoding: .utf8) {
                weeklyWaterHistoryData = str
            }
        }
    }
    
    var weeklyWaterData: [(day: String, ml: Int)] {
        let calendar = Calendar.current
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var result: [(day: String, ml: Int)] = []
        let history = weeklyWaterHistory
        
        for offset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let dayStr = dayFormatter.string(from: date)
            let dateStr = dateFormatter.string(from: date)
            
            if dateStr == todayDateString {
                result.append((day: dayStr, ml: waterIntakeML))
            } else if let record = history.first(where: { $0.date == dateStr }) {
                result.append((day: dayStr, ml: record.ml))
            } else {
                result.append((day: dayStr, ml: 0))
            }
        }
        return result
    }
    
    func addWater(ml: Int) {
        checkWaterDailyReset()
        waterIntakeML += ml
        var log = waterLog
        log.append(WaterLogEntry(time: Date(), ml: ml))
        waterLog = log
    }
    
    func resetWater() {
        waterIntakeML = 0
        waterLog = []
    }
    
    private func checkWaterDailyReset() {
        if waterDate != todayDateString {
            // save yesterday's total before reset
            if !waterDate.isEmpty && waterIntakeML > 0 {
                var history = weeklyWaterHistory
                history.append(DailyWaterRecord(date: waterDate, ml: waterIntakeML))
                weeklyWaterHistory = history
            }
            waterIntakeML = 0
            waterLog = []
            waterDate = todayDateString
        }
    }
    
    // ========================================
    // NOTES COMPUTED PROPERTIES & CRUD
    // ========================================
    
    var notes: [NoteEntry] {
        get {
            let data = Data(notesData.utf8)
            return (try? JSONDecoder().decode([NoteEntry].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                notesData = str
            }
        }
    }
    
    func addNote(_ note: NoteEntry) {
        var list = notes
        list.insert(note, at: 0)
        notes = list
    }
    
    func updateNote(_ updated: NoteEntry) {
        var list = notes
        if let idx = list.firstIndex(where: { $0.id == updated.id }) {
            list[idx] = updated
        }
        notes = list
    }
    
    func deleteNote(id: UUID) {
        var list = notes
        list.removeAll { $0.id == id }
        notes = list
    }
    
    func toggleNotePin(id: UUID) {
        var list = notes
        if let idx = list.firstIndex(where: { $0.id == id }) {
            list[idx].isPinned.toggle()
        }
        notes = list
    }
    
    func updateNoteColor(id: UUID, color: String) {
        var list = notes
        if let idx = list.firstIndex(where: { $0.id == id }) {
            list[idx].colorTag = color
        }
        notes = list
    }
    
    // ========================================
    // INITIALIZATION
    // ========================================
    
    init() {
        requestNotificationPermission()
        checkDailyReset()
        checkWaterDailyReset()
    }
    
    // ========================================
    // MAIN FUNCTIONS
    // ========================================
    
    func startSession() {
        stopTimer()
        
        timeRemaining = workMinutes * 60
        isOnBreak = false
        isTimerRunning = true
        sessionStartTime = Date()
        
        playAlertSound()
        
        // start Dynamic Island Live Activity
        LiveActivityManager.shared.startLiveActivity(
            taskName: currentTaskName,
            category: selectedCategory,
            totalSeconds: Int(timeRemaining)
        )
        
        scheduleNotification(
            seconds: timeRemaining,
            title: "Time's up! ⏰",
            body: "Time for a break. Rest your eyes."
        )
        
        focusTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tick()
            }
        }
    }
    
    func stopTimer() {
        focusTimer?.invalidate()
        focusTimer = nil
        isTimerRunning = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // end Dynamic Island Live Activity
        LiveActivityManager.shared.endLiveActivity()
    }
    
    // ========================================
    // PRIVATE METHODS
    // ========================================
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            
            // update Dynamic Island every second
            LiveActivityManager.shared.updateLiveActivity(
                timeRemaining: Int(timeRemaining),
                totalDuration: Int(isOnBreak ? breakMinutes * 60 : workMinutes * 60),
                taskName: currentTaskName,
                categoryIcon: selectedCategory.icon,
                isBreak: isOnBreak
            )
        } else {
            switchMode()
        }
    }
    
    private func switchMode() {
        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(.success)
        playAlertSound()
        
        if isOnBreak {
            isOnBreak = false
            recordCompletedSession()
            stopTimer()
        } else {
            isOnBreak = true
            timeRemaining = breakMinutes * 60
            motivationalQuote = quotes.randomElement() ?? "Take it easy"
            
            // update Dynamic Island for break mode
            LiveActivityManager.shared.startLiveActivity(
                taskName: currentTaskName,
                category: selectedCategory,
                totalSeconds: Int(timeRemaining),
                isBreak: true
            )
            
            scheduleNotification(
                seconds: timeRemaining,
                title: "Break's over!",
                body: "Let's get back to focusing."
            )
        }
    }
    
    private func playAlertSound() {
        let selectedSound = AlertSound(rawValue: alertSoundChoice) ?? .default
        AudioServicesPlaySystemSound(selectedSound.soundID)
    }
    
    // ========================================
    // STATISTICS
    // ========================================
    
    private func checkDailyReset() {
        if lastDate != todayDateString {
            todayCompleted = 0
            todayFocusMinutes = 0
            lastDate = todayDateString
        }
    }
    
    private func recordCompletedSession() {
        let minutes = Int(workMinutes)
        
        totalCompleted += 1
        todayCompleted += 1
        totalFocusTime += minutes
        todayFocusMinutes += minutes
        lastDate = todayDateString
        
        // save to history
        let entry = SessionEntry(
            date: Date(),
            minutes: minutes,
            category: selectedCategory,
            taskName: currentTaskName
        )
        var history = sessionHistory
        history.append(entry)
        sessionHistory = history
        
        updateStreak()
        checkAchievements()
    }
    
    private func updateStreak() {
        let today = todayDateString
        
        if lastStreakDay == today { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let lastDay = formatter.date(from: lastStreakDay),
           let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
           Calendar.current.isDate(lastDay, inSameDayAs: yesterday) {
            currentStreak += 1
        } else if lastStreakDay != today {
            currentStreak = 1
        }
        
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
        
        lastStreakDay = today
    }
    
    // ========================================
    // ACHIEVEMENTS
    // ========================================
    
    private func checkAchievements() {
        var unlocked = unlockedAchievements
        
        let checks: [(Achievement, Bool)] = [
            (.firstSession, totalCompleted >= 1),
            (.tenSessions, totalCompleted >= 10),
            (.marathon, workMinutes >= 60),
            (.weekStreak, currentStreak >= 7),
            (.hundredMinutes, totalFocusTime >= 100),
            (.nightOwl, Calendar.current.component(.hour, from: Date()) >= 22)
        ]
        
        for (achievement, condition) in checks {
            if condition && !unlocked.contains(achievement.rawValue) {
                unlocked.insert(achievement.rawValue)
                // trigger animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        self.newlyUnlockedAchievement = achievement
                    }
                }
            }
        }
        
        unlockedAchievements = unlocked
    }
    
    func isAchievementUnlocked(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains(achievement.rawValue)
    }
    
    func dismissAchievementAlert() {
        withAnimation {
            newlyUnlockedAchievement = nil
        }
    }
    
    // ========================================
    // NOTIFICATIONS
    // ========================================
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    func scheduleNotification(seconds: Double, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if !currentTaskName.isEmpty {
            content.subtitle = "📝 \(currentTaskName)"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, seconds),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

typealias TimerManager = FocusModeTimer
