import WidgetKit
import SwiftUI
import ActivityKit

// ========================================
// ACTIVITY ATTRIBUTES (mirrored from main app)
// ========================================
// must be duplicated here since widget extension is a separate target

struct UPTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: Int
        var totalDuration: Int
        var taskName: String
        var categoryIcon: String
        var isOnBreak: Bool
    }
    var sessionCategory: String
}

// ========================================
// DYNAMIC ISLAND & LOCK SCREEN LIVE ACTIVITY
// ========================================

struct UPTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: UPTimerAttributes.self) { context in
            
            // ========================================
            // LOCK SCREEN BANNER
            // ========================================
            
            HStack(spacing: 14) {
                // category icon
                ZStack {
                    Circle()
                        .fill(context.state.isOnBreak ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: context.state.isOnBreak ? "cup.and.saucer.fill" : context.state.categoryIcon)
                        .font(.title3)
                        .foregroundStyle(context.state.isOnBreak ? .green : .blue)
                }
                
                // text info
                VStack(alignment: .leading, spacing: 3) {
                    Text(context.state.isOnBreak ? "Break Time" : context.state.taskName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(context.attributes.sessionCategory)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // countdown
                VStack(alignment: .trailing, spacing: 3) {
                    Text(formatSeconds(context.state.timeRemaining))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(context.state.isOnBreak ? .green : .blue)
                    
                    // progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            Capsule()
                                .fill(context.state.isOnBreak ? Color.green : Color.blue)
                                .frame(
                                    width: geo.size.width * progress(state: context.state),
                                    height: 4
                                )
                        }
                    }
                    .frame(width: 80, height: 4)
                }
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            
        } dynamicIsland: { context in
            
            // ========================================
            // DYNAMIC ISLAND
            // ========================================
            
            DynamicIsland {
                // expanded region — top leading
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: context.state.isOnBreak ? "cup.and.saucer.fill" : context.state.categoryIcon)
                            .font(.title3)
                            .foregroundStyle(context.state.isOnBreak ? .green : .cyan)
                        
                        Text(context.state.isOnBreak ? "Break" : context.attributes.sessionCategory)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // expanded region — top trailing
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatSeconds(context.state.timeRemaining))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(context.state.isOnBreak ? .green : .cyan)
                }
                
                // expanded region — bottom
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        // task name
                        Text(context.state.taskName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        // progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 5)
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: context.state.isOnBreak
                                                ? [.green.opacity(0.7), .green]
                                                : [.cyan.opacity(0.7), .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geo.size.width * progress(state: context.state),
                                        height: 5
                                    )
                            }
                        }
                        .frame(height: 5)
                    }
                }
                
            } compactLeading: {
                // compact — left pill
                Image(systemName: context.state.isOnBreak ? "cup.and.saucer.fill" : "timer")
                    .font(.caption)
                    .foregroundStyle(context.state.isOnBreak ? .green : .cyan)
                
            } compactTrailing: {
                // compact — right pill
                Text(formatSeconds(context.state.timeRemaining))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(context.state.isOnBreak ? .green : .cyan)
                
            } minimal: {
                // minimal — single circular region
                Image(systemName: context.state.isOnBreak ? "cup.and.saucer.fill" : "timer")
                    .font(.caption2)
                    .foregroundStyle(context.state.isOnBreak ? .green : .cyan)
            }
        }
    }
    
    // ========================================
    // HELPERS
    // ========================================
    
    private func formatSeconds(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func progress(state: UPTimerAttributes.ContentState) -> CGFloat {
        guard state.totalDuration > 0 else { return 0 }
        return CGFloat(state.totalDuration - state.timeRemaining) / CGFloat(state.totalDuration)
    }
}

// ========================================
// WIDGET BUNDLE
// ========================================

@main
struct UPWidgetBundle: WidgetBundle {
    var body: some Widget {
        UPTimerLiveActivity()
    }
}
