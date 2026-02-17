import ActivityKit
import SwiftUI

// ========================================
// LIVE ACTIVITY ATTRIBUTES
// ========================================
// shared definition for Dynamic Island + Lock Screen Live Activity

struct UPTimerAttributes: ActivityAttributes {
    
    // static context — doesn't change during the activity
    public struct ContentState: Codable, Hashable {
        var timeRemaining: Int      // seconds left
        var totalDuration: Int      // total seconds
        var taskName: String        // what user is working on
        var categoryIcon: String    // SF Symbol for category
        var isOnBreak: Bool         // break or focus mode
    }
    
    // fixed for the lifetime of the activity
    var sessionCategory: String
}

// ========================================
// LIVE ACTIVITY MANAGER
// ========================================
// handles starting, updating, and ending Live Activities

class LiveActivityManager {
    
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<UPTimerAttributes>? = nil
    
    private init() {}
    
    // check if Live Activities are supported
    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    // start a new Live Activity when timer begins
    func startLiveActivity(
        taskName: String,
        category: SessionCategory,
        totalSeconds: Int,
        isBreak: Bool = false
    ) {
        guard isSupported else { return }
        
        // end any existing activity first
        endLiveActivity()
        
        let attributes = UPTimerAttributes(sessionCategory: category.rawValue)
        
        let state = UPTimerAttributes.ContentState(
            timeRemaining: totalSeconds,
            totalDuration: totalSeconds,
            taskName: taskName.isEmpty ? "Focus Session" : taskName,
            categoryIcon: category.icon,
            isOnBreak: isBreak
        )
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        do {
            currentActivity = try Activity<UPTimerAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    // update the Live Activity each second
    func updateLiveActivity(
        timeRemaining: Int,
        totalDuration: Int,
        taskName: String,
        categoryIcon: String,
        isBreak: Bool
    ) {
        guard let activity = currentActivity else { return }
        
        let state = UPTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            totalDuration: totalDuration,
            taskName: taskName.isEmpty ? "Focus Session" : taskName,
            categoryIcon: categoryIcon,
            isOnBreak: isBreak
        )
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    // end the Live Activity
    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let finalState = UPTimerAttributes.ContentState(
            timeRemaining: 0,
            totalDuration: 0,
            taskName: "Session Complete",
            categoryIcon: "checkmark.circle.fill",
            isOnBreak: false
        )
        
        let content = ActivityContent(state: finalState, staleDate: nil)
        
        Task {
            await activity.end(content, dismissalPolicy: .default)
        }
        
        currentActivity = nil
    }
}
