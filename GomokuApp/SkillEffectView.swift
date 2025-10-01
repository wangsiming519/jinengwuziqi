import SwiftUI

struct SkillEffectView: View {
    @State private var animationPhase: Double = 0
    @State private var particles: [Particle] = []
    @State private var shockWaveScale: Double = 0
    @State private var fadeOpacity: Double = 1
    
    let cellSize: CGFloat = 24
    
    var body: some View {
        ZStack {
            // 冲击波效果
            Circle()
                .stroke(Color.red.opacity(0.8), lineWidth: 3)
                .frame(width: cellSize * shockWaveScale, height: cellSize * shockWaveScale)
                .opacity(1 - shockWaveScale / 3)
            
            Circle()
                .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                .frame(width: cellSize * shockWaveScale * 0.7, height: cellSize * shockWaveScale * 0.7)
                .opacity(1 - shockWaveScale / 3)
            
            // 中心爆炸效果
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.8))
                    .frame(width: cellSize * (1 + animationPhase * 0.5), height: cellSize * (1 + animationPhase * 0.5))
                    .opacity(fadeOpacity)
                
                Circle()
                    .fill(Color.orange.opacity(0.6))
                    .frame(width: cellSize * (0.7 + animationPhase * 0.3), height: cellSize * (0.7 + animationPhase * 0.3))
                    .opacity(fadeOpacity)
                
                Circle()
                    .fill(Color.yellow.opacity(0.9))
                    .frame(width: cellSize * (0.4 + animationPhase * 0.2), height: cellSize * (0.4 + animationPhase * 0.2))
                    .opacity(fadeOpacity)
            }
            
            // 粒子效果
            ForEach(particles.indices, id: \.self) { index in
                let particle = particles[index]
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
            
            // 飞沙走石文字特效
            Text("飞沙走石")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .red, radius: 2)
                .offset(y: -cellSize * 1.5)
                .opacity(fadeOpacity)
                .scaleEffect(1 + animationPhase * 0.3)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // 创建粒子
        createParticles()
        
        // 主动画
        withAnimation(.easeOut(duration: 1.0)) {
            animationPhase = 1.0
            shockWaveScale = 3.0
            fadeOpacity = 0.0
        }
        
        // 粒子动画
        animateParticles()
    }
    
    private func createParticles() {
        particles = []
        let particleCount = 20
        
        for i in 0..<particleCount {
            let angle = Double(i) * 2 * Double.pi / Double(particleCount)
            let distance = Double.random(in: 20...50)
            
            let particle = Particle(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                size: Double.random(in: 2...6),
                color: [Color.red, Color.orange, Color.yellow, Color.brown].randomElement() ?? Color.red,
                opacity: 1.0
            )
            particles.append(particle)
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            let delay = Double(i) * 0.02
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.8)) {
                    particles[i].x *= 2.0
                    particles[i].y *= 2.0
                    particles[i].opacity = 0.0
                    particles[i].size *= 0.5
                }
            }
        }
    }
}

struct Particle {
    var x: Double
    var y: Double
    var size: Double
    var color: Color
    var opacity: Double
}

#Preview {
    SkillEffectView()
        .frame(width: 100, height: 100)
        .background(Color.brown.opacity(0.3))
}