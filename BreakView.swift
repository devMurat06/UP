import SwiftUI

// ========================================
// BREAK VIEW — Full-screen forced break
// ========================================
// user can't dismiss until timer runs out

struct BreakView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @State private var showBreathingMode: Bool = false
    @State private var floatingCircles: [FloatingCircle] = []
    
    struct FloatingCircle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let opacity: Double
        let color: Color
    }
    
    var body: some View {
        ZStack {
            // dark background
            Color.black.ignoresSafeArea()
            
            // floating ambient circles
            ForEach(floatingCircles) { circle in
                Circle()
                    .fill(circle.color.opacity(circle.opacity))
                    .frame(width: circle.size, height: circle.size)
                    .blur(radius: circle.size * 0.3)
                    .offset(x: circle.x, y: circle.y)
            }
            
            VStack(spacing: 28) {
                Spacer()
                
                // header with SF Symbol
                HStack(spacing: 10) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.title)
                        .foregroundStyle(.cyan)
                        .symbolEffect(.pulse)
                    Text("BREAK TIME")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                // motivational quote
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.cyan.opacity(0.7))
                    Text(manager.motivationalQuote)
                        .font(.title3)
                        .italic()
                        .foregroundStyle(.cyan.opacity(0.8))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                
                // task name
                if !manager.currentTaskName.isEmpty {
                    Label(manager.currentTaskName, systemImage: "note.text")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                // main content — breathing or animation
                if showBreathingMode {
                    BreathingExerciseView()
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    LottieView()
                        .frame(width: 240, height: 240)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                                .blur(radius: 30)
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                }
                
                // mode toggle
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showBreathingMode.toggle()
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Label(
                        showBreathingMode ? "Back to Animation" : "Breathing Exercise",
                        systemImage: showBreathingMode ? "play.circle.fill" : "lungs.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(22)
                }
                
                // countdown
                VStack(spacing: 8) {
                    Text("Screen unlocks in")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    Text(formatTime(manager.timeRemaining))
                        .font(.system(size: 52, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green)
                        .contentTransition(.numericText())
                        .animation(.default, value: manager.timeRemaining)
                }
                
                Spacer()
            }
            .padding()
        }
        .interactiveDismissDisabled(true)
        .statusBar(hidden: true)
        .onAppear { generateFloatingCircles() }
    }
    
    // generate ambient floating circles
    private func generateFloatingCircles() {
        let colors: [Color] = [.blue, .cyan, .purple, .indigo]
        for _ in 0..<12 {
            floatingCircles.append(FloatingCircle(
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -400...400),
                size: CGFloat.random(in: 40...120),
                opacity: Double.random(in: 0.03...0.1),
                color: colors.randomElement() ?? .blue
            ))
        }
    }
    
    func formatTime(_ totalSeconds: Double) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
