import SwiftUI

// ========================================
// ACHIEVEMENTS VIEW
// ========================================
// Badge grid with locked/unlocked states and glow effects

struct AchievementsView: View {
    
    @ObservedObject var manager: FocusModeTimer
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // header
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                Text("Achievements")
                    .font(.headline)
                Spacer()
                Text("\(unlockedCount)/\(Achievement.allCases.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            // badge grid
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Achievement.allCases) { achievement in
                    achievementBadge(achievement)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private var unlockedCount: Int {
        Achievement.allCases.filter { manager.isAchievementUnlocked($0) }.count
    }
    
    @ViewBuilder
    private func achievementBadge(_ achievement: Achievement) -> some View {
        let isUnlocked = manager.isAchievementUnlocked(achievement)
        
        VStack(spacing: 8) {
            ZStack {
                // glow background for unlocked
                if isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: achievement.gradient.map { $0.opacity(0.3) },
                                center: .center,
                                startRadius: 5,
                                endRadius: 35
                            )
                        )
                        .frame(width: 60, height: 60)
                        .blur(radius: 4)
                }
                
                Circle()
                    .fill(
                        isUnlocked
                        ? LinearGradient(colors: achievement.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: achievement.icon)
                            .font(.title2)
                            .foregroundStyle(isUnlocked ? .white : .gray)
                    )
                    .shadow(color: isUnlocked ? achievement.gradient[0].opacity(0.4) : .clear, radius: 6)
            }
            
            Text(achievement.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(isUnlocked ? .primary : .secondary)
                .lineLimit(1)
            
            Text(achievement.description)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// ========================================
// ACHIEVEMENT UNLOCK OVERLAY
// ========================================
// confetti-style animation shown when a new badge is unlocked

struct AchievementUnlockOverlay: View {
    
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var particles: [ParticleData] = []
    
    struct ParticleData: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let color: Color
        let size: CGFloat
    }
    
    var body: some View {
        ZStack {
            // dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            // floating particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(opacity)
            }
            
            // badge card
            VStack(spacing: 16) {
                Text("Achievement Unlocked!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: achievement.gradient.map { $0.opacity(0.4) },
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(
                            LinearGradient(colors: achievement.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: achievement.icon)
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        )
                        .shadow(color: achievement.gradient[0].opacity(0.6), radius: 12)
                }
                
                Text(achievement.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Button(action: onDismiss) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: achievement.gradient, startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(25)
                }
                .padding(.top, 4)
            }
            .padding(32)
            .scaleEffect(scale)
        }
        .opacity(opacity)
        .onAppear {
            generateParticles()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func generateParticles() {
        let colors = achievement.gradient + [.white, .yellow]
        for _ in 0..<20 {
            particles.append(ParticleData(
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -250...250),
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 4...10)
            ))
        }
    }
}
