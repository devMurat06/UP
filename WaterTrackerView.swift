import SwiftUI

// ========================================
// WATER TRACKER VIEW
// ========================================
// Track daily water intake with animated glass visuals

struct WaterTrackerView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @State private var animateWave = false
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    // water glass visual
                    waterGlassCard
                    
                    // quick add buttons
                    quickAddSection
                    
                    // today's log
                    todayLog
                    
                    // weekly water chart
                    weeklyWaterChart
                    
                    // tips card
                    hydrationTip
                    
                }
                .padding()
            }
            .navigationTitle("Hydration")
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // ========================================
    // WATER GLASS VISUAL
    // ========================================
    
    private var waterGlassCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.title3)
                    .foregroundStyle(.cyan)
                    .symbolEffect(.pulse, isActive: manager.waterIntakeML > 0)
                Text("Daily Hydration")
                    .font(.headline)
                Spacer()
                Text("\(manager.waterIntakeML) / \(manager.waterGoalML) ml")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.cyan)
            }
            
            // glass visual
            ZStack {
                // glass outline
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 3)
                    .frame(width: 140, height: 200)
                
                // water fill
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.4), .blue.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 134, height: max(194 * waterProgress, 8))
                    .frame(height: 194, alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .animation(.easeInOut(duration: 0.6), value: manager.waterIntakeML)
                
                // wave overlay
                if manager.waterIntakeML > 0 {
                    WaveShape(offset: animateWave ? 0 : .pi * 2, percent: waterProgress)
                        .fill(Color.cyan.opacity(0.2))
                        .frame(width: 134, height: 194)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .onAppear {
                            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                animateWave = true
                            }
                        }
                }
                
                // percentage text
                VStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(Int(waterProgress * 100))%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 210)
            
            // glass count
            HStack(spacing: 4) {
                let glasses = manager.waterIntakeML / 250
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: index < glasses ? "cup.and.saucer.fill" : "cup.and.saucer")
                        .font(.caption)
                        .foregroundStyle(index < glasses ? .cyan : .secondary.opacity(0.3))
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private var waterProgress: CGFloat {
        guard manager.waterGoalML > 0 else { return 0 }
        return min(CGFloat(manager.waterIntakeML) / CGFloat(manager.waterGoalML), 1.0)
    }
    
    // ========================================
    // QUICK ADD BUTTONS
    // ========================================
    
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text("Quick Add")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 10) {
                waterButton(ml: 150, icon: "drop", label: "Small")
                waterButton(ml: 250, icon: "drop.fill", label: "Glass")
                waterButton(ml: 500, icon: "waterbottle", label: "Bottle")
                waterButton(ml: 750, icon: "waterbottle.fill", label: "Large")
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private func waterButton(ml: Int, icon: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                manager.addWater(ml: ml)
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                Text("\(ml)ml")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.cyan.opacity(0.08))
            .foregroundStyle(.cyan)
            .cornerRadius(14)
        }
    }
    
    // ========================================
    // TODAY'S LOG
    // ========================================
    
    private var todayLog: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title3)
                    .foregroundStyle(.indigo)
                Text("Today's Log")
                    .font(.headline)
                Spacer()
                
                if manager.waterIntakeML > 0 {
                    Button {
                        withAnimation {
                            manager.resetWater()
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            let entries = manager.waterLog
            if entries.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "drop.degreesign")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary.opacity(0.4))
                        Text("No water logged yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(entries.reversed()) { entry in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.cyan.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "drop.fill")
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                            )
                        
                        Text("\(entry.ml) ml")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(entry.time, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // ========================================
    // WEEKLY WATER CHART
    // ========================================
    
    private var weeklyWaterChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundStyle(.cyan)
                Text("This Week")
                    .font(.headline)
                Spacer()
            }
            
            let data = manager.weeklyWaterData
            let maxML = max(data.map(\.ml).max() ?? 1, 1)
            
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 6) {
                        if item.ml > 0 {
                            Text("\(item.ml / 1000).\(item.ml % 1000 / 100)L")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.4), .cyan],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: max(CGFloat(item.ml) / CGFloat(maxML) * 100, 4))
                        
                        Text(item.day)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(index == data.count - 1 ? .primary : .secondary)
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
    
    // ========================================
    // HYDRATION TIP
    // ========================================
    
    private var hydrationTip: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundStyle(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Hydration Tip")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text(currentTip)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.06))
        .cornerRadius(16)
    }
    
    private var currentTip: String {
        let tips = [
            "Drink a glass of water every 30 minutes during focus sessions.",
            "Start your day with a full glass of water before anything else.",
            "Your brain is 75% water — stay hydrated to stay focused!",
            "Room temperature water is absorbed faster than cold water.",
            "Set a water reminder for every Pomodoro break.",
            "Dehydration can reduce concentration by up to 25%."
        ]
        let index = Calendar.current.component(.hour, from: Date()) % tips.count
        return tips[index]
    }
}

// ========================================
// WAVE SHAPE (animated water wave)
// ========================================

struct WaveShape: Shape {
    var offset: Double
    var percent: CGFloat
    
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterHeight = rect.height * (1 - percent)
        let waveHeight: CGFloat = 6
        
        path.move(to: CGPoint(x: 0, y: waterHeight))
        
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relX = x / rect.width
            let sine = sin(relX * .pi * 2 + offset)
            let y = waterHeight + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}
