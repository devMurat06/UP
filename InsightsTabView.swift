import SwiftUI

// ========================================
// INSIGHTS TAB
// ========================================
// Focus score, weekly chart, heatmap, achievements, category breakdown

struct InsightsTabView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @State private var scoreAnimated: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // focus score card
                    focusScoreCard
                    
                    // activity rings
                    ActivityRingView(manager: manager)
                    
                    // weekly bar chart
                    weeklyChart
                    
                    // category breakdown
                    categoryCard
                    
                    // heatmap
                    HeatmapView(manager: manager)
                    
                    // achievements
                    AchievementsView(manager: manager)
                    
                }
                .padding()
            }
            .navigationTitle("Insights")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // ========================================
    // FOCUS SCORE CARD
    // ========================================
    
    private var focusScoreCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "gauge.open.with.lines.needle.33percent")
                    .font(.title3)
                    .foregroundStyle(.purple)
                    .symbolEffect(.pulse, isActive: scoreAnimated)
                Text("Focus Score")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 20) {
                // large score number
                Text("\(scoreAnimated ? manager.focusScore : 0)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)
                    .contentTransition(.numericText())
                
                VStack(alignment: .leading, spacing: 6) {
                    // progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.15))
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [scoreColor.opacity(0.7), scoreColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(scoreAnimated ? manager.focusScore : 0) / 100)
                                .animation(.easeOut(duration: 1.0), value: scoreAnimated)
                        }
                    }
                    .frame(height: 10)
                    
                    // insight text
                    Text(manager.focusInsight)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    
                    // today's stats summary
                    HStack(spacing: 12) {
                        Label("\(manager.todayCompleted) sessions", systemImage: "checkmark.circle")
                        Label("\(manager.todayFocusMinutes) min", systemImage: "clock")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 1.0)) {
                    scoreAnimated = true
                }
            }
        }
    }
    
    private var scoreColor: Color {
        switch manager.focusScore {
        case 0..<30: return .red
        case 30..<60: return .orange
        case 60..<80: return .blue
        default: return .green
        }
    }
    
    // ========================================
    // WEEKLY BAR CHART
    // ========================================
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text("This Week")
                    .font(.headline)
                Spacer()
            }
            
            let data = manager.weeklyFocusData
            let maxMinutes = max(data.map(\.minutes).max() ?? 1, 1)
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 6) {
                        // value label
                        if item.minutes > 0 {
                            Text("\(item.minutes)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        
                        // bar
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.5), .blue],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: max(CGFloat(item.minutes) / CGFloat(maxMinutes) * 100, 4))
                        
                        // day label
                        Text(item.day)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(isToday(index: index, total: data.count) ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private func isToday(index: Int, total: Int) -> Bool {
        index == total - 1
    }
    
    // ========================================
    // CATEGORY BREAKDOWN
    // ========================================
    
    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.title3)
                    .foregroundStyle(.purple)
                Text("Category Breakdown")
                    .font(.headline)
                Spacer()
            }
            
            let breakdown = manager.categoryBreakdown
            let total = max(breakdown.reduce(0) { $0 + $1.minutes }, 1)
            
            ForEach(breakdown, id: \.category) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.category.icon)
                        .font(.body)
                        .foregroundStyle(item.category.color)
                        .frame(width: 24)
                    
                    Text(item.category.rawValue)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    // mini progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.1))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(item.category.color.opacity(0.7))
                                .frame(width: geo.size.width * CGFloat(item.minutes) / CGFloat(total))
                        }
                    }
                    .frame(width: 80, height: 8)
                    
                    Text("\(item.minutes)m")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
}
