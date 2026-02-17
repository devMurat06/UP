import SwiftUI

// ========================================
// FOCUS INTENSITY HEATMAP
// ========================================
// 4-week calendar grid showing daily focus intensity
// inspired by GitHub's contribution graph

struct HeatmapView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @State private var selectedDay: Date? = nil
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // header
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text("Focus Heatmap")
                    .font(.headline)
                Spacer()
                Text("4 weeks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // day labels row
            HStack(spacing: 6) {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // heatmap grid
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(heatmapDays(), id: \.self) { date in
                    let minutes = manager.heatmapData[Calendar.current.startOfDay(for: date)] ?? 0
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(cellColor(minutes: minutes))
                        .frame(height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(selectedDay == date ? Color.white : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDay = selectedDay == date ? nil : date
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                }
            }
            
            // selected day detail
            if let day = selectedDay {
                let mins = manager.heatmapData[Calendar.current.startOfDay(for: day)] ?? 0
                HStack(spacing: 6) {
                    Image(systemName: mins > 0 ? "flame.fill" : "minus.circle")
                        .foregroundStyle(mins > 0 ? .orange : .secondary)
                    Text(dayFormatted(day))
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text(mins > 0 ? "\(mins) min focused" : "No sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .transition(.scale.combined(with: .opacity))
            }
            
            // legend
            HStack(spacing: 4) {
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach([0, 15, 30, 60, 120], id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(minutes: level))
                        .frame(width: 14, height: 14)
                }
                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // generate 28 days (4 weeks) ending today
    private func heatmapDays() -> [Date] {
        let calendar = Calendar.current
        var days: [Date] = []
        for offset in (0..<28).reversed() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                days.append(calendar.startOfDay(for: date))
            }
        }
        return days
    }
    
    // color based on focus minutes
    private func cellColor(minutes: Int) -> Color {
        switch minutes {
        case 0: return Color(UIColor.systemGray5)
        case 1..<15: return Color.green.opacity(0.25)
        case 15..<30: return Color.green.opacity(0.45)
        case 30..<60: return Color.green.opacity(0.65)
        case 60..<120: return Color.green.opacity(0.85)
        default: return Color.green
        }
    }
    
    private func dayFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, EEE"
        return formatter.string(from: date)
    }
}
