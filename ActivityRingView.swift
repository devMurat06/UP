import SwiftUI

// ========================================
// ACTIVITY RING VIEW
// ========================================
// 3 concentric rings like Apple Watch fitness rings
// inner = sessions, middle = minutes, outer = streak

struct ActivityRingView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @State private var animateRings = false
    
    var body: some View {
        VStack(spacing: 16) {
            
            // header
            HStack(spacing: 8) {
                Image(systemName: "figure.mind.and.body")
                    .font(.title3)
                    .foregroundStyle(.green)
                Text("Daily Progress")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 24) {
                // rings
                ZStack {
                    // outer ring — streak (orange)
                    ringLayer(
                        progress: animateRings ? streakProgress : 0,
                        color: .orange,
                        size: 130,
                        lineWidth: 14
                    )
                    
                    // middle ring — minutes (blue)
                    ringLayer(
                        progress: animateRings ? minuteProgress : 0,
                        color: .blue,
                        size: 100,
                        lineWidth: 14
                    )
                    
                    // inner ring — sessions (green)
                    ringLayer(
                        progress: animateRings ? sessionProgress : 0,
                        color: .green,
                        size: 70,
                        lineWidth: 14
                    )
                    
                    // center icon
                    Image(systemName: "target")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                .frame(width: 140, height: 140)
                
                // labels
                VStack(alignment: .leading, spacing: 14) {
                    ringLabel(
                        color: .green,
                        icon: "checkmark.circle.fill",
                        title: "Sessions",
                        value: "\(manager.todayCompleted)/\(manager.dailySessionGoal)"
                    )
                    ringLabel(
                        color: .blue,
                        icon: "clock.fill",
                        title: "Minutes",
                        value: "\(manager.todayFocusMinutes)/\(manager.dailyMinuteGoal)"
                    )
                    ringLabel(
                        color: .orange,
                        icon: "flame.fill",
                        title: "Streak",
                        value: "\(manager.currentStreak) days"
                    )
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                animateRings = true
            }
        }
    }
    
    // progress values (0.0 to 1.0)
    private var sessionProgress: CGFloat {
        guard manager.dailySessionGoal > 0 else { return 0 }
        return min(CGFloat(manager.todayCompleted) / CGFloat(manager.dailySessionGoal), 1.0)
    }
    
    private var minuteProgress: CGFloat {
        guard manager.dailyMinuteGoal > 0 else { return 0 }
        return min(CGFloat(manager.todayFocusMinutes) / CGFloat(manager.dailyMinuteGoal), 1.0)
    }
    
    private var streakProgress: CGFloat {
        return min(CGFloat(manager.currentStreak) / 7.0, 1.0)
    }
    
    // single ring layer
    private func ringLayer(progress: CGFloat, color: Color, size: CGFloat, lineWidth: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [color, color.opacity(0.6), color], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
    
    // ring label row
    private func ringLabel(color: Color, icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}
