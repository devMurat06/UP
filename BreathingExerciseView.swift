import SwiftUI

// ========================================
// BREATHING EXERCISE VIEW
// ========================================

// 4-7-8 breathing technique: 4s inhale, 7s hold, 8s exhale
// scientifically proven to reduce anxiety and stress
// I found this technique online and thought it would be cool to add

struct BreathingExerciseView: View {
    
    // current state
    @State private var breathPhase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.5
    @State private var isAnimating: Bool = false
    @State private var cycleCount: Int = 0
    
    // breathing phases
    enum BreathPhase {
        case inhale  // breathe in (4 seconds)
        case hold    // hold (7 seconds)
        case exhale  // breathe out (8 seconds)
        
        var displayText: String {
            switch self {
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            }
        }
        
        var duration: Double {
            switch self {
            case .inhale: return 4.0
            case .hold: return 7.0
            case .exhale: return 8.0
            }
        }
        
        var color: Color {
            switch self {
            case .inhale: return .blue
            case .hold: return .purple
            case .exhale: return .green
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            // title
            Text("4-7-8 Breathing")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            // main animation circle
            ZStack {
                // outer ring - fixed
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 3)
                    .frame(width: 180, height: 180)
                
                // inner circle - grows and shrinks with breath
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [breathPhase.color.opacity(0.8), breathPhase.color.opacity(0.3)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 90
                        )
                    )
                    .frame(width: 150, height: 150)
                    .scaleEffect(circleScale)
                    .shadow(color: breathPhase.color.opacity(0.5), radius: 20)
                
                // phase text
                Text(breathPhase.displayText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // cycle counter
            if cycleCount > 0 {
                Text("\(cycleCount) cycles completed")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // start/stop button
            Button(action: toggleBreathing) {
                Text(isAnimating ? "Stop" : "Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(isAnimating ? Color.red.opacity(0.6) : Color.blue.opacity(0.6))
                    .cornerRadius(25)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    // ========================================
    // METHODS
    // ========================================
    
    private func toggleBreathing() {
        if isAnimating {
            stopBreathing()
        } else {
            startBreathing()
        }
    }
    
    private func startBreathing() {
        isAnimating = true
        breathPhase = .inhale
        runBreathCycle()
    }
    
    private func stopBreathing() {
        isAnimating = false
        // return circle to starting size
        withAnimation(.easeOut(duration: 0.5)) {
            circleScale = 0.5
        }
    }
    
    private func runBreathCycle() {
        guard isAnimating else { return }
        
        // haptic feedback - feel the phase change
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        switch breathPhase {
        case .inhale:
            // breathe in - circle grows
            withAnimation(.easeInOut(duration: breathPhase.duration)) {
                circleScale = 1.0
            }
            // after 4 seconds, switch to hold phase
            DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
                self.breathPhase = .hold
                self.runBreathCycle()
            }
            
        case .hold:
            // hold - circle stays same (no animation)
            // after 7 seconds, switch to exhale phase
            DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
                self.breathPhase = .exhale
                self.runBreathCycle()
            }
            
        case .exhale:
            // breathe out - circle shrinks
            withAnimation(.easeInOut(duration: breathPhase.duration)) {
                circleScale = 0.5
            }
            // after 8 seconds, complete cycle and restart
            DispatchQueue.main.asyncAfter(deadline: .now() + breathPhase.duration) {
                self.cycleCount += 1
                self.breathPhase = .inhale
                self.runBreathCycle()
            }
        }
    }
}

// ========================================
// PREVIEW
// ========================================

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BreathingExerciseView()
    }
}

