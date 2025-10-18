import SwiftUI

struct ModernSplashView: View {
    @Binding var isActive: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var particlesOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles
            SplashParticlesView()
                .opacity(particlesOpacity)
            
            VStack(spacing: 20) {
                // App icon with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                        .scaleEffect(scale)
                    
                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan,
                                    Color.blue
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .cyan.opacity(0.5), radius: 30)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                    
                    // Icon
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                }
                
                // App name with animation
                VStack(spacing: 10) {
                    Text("CoderQuest")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(opacity)
                    
                    Text("Master Programming Skills")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(opacity)
                }
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 8, height: 8)
                            .scaleEffect(scale > 0.8 ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: scale
                            )
                    }
                }
                .opacity(opacity)
                .padding(.top, 30)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startAnimations()
            
            // Navigate to main view after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
    }
    
    private func startAnimations() {
        // Scale and fade in animation
        withAnimation(.easeOut(duration: 1.0)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Continuous rotation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Particles fade in
        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
            particlesOpacity = 1.0
        }
    }
}

struct SplashParticlesView: View {
    @State private var particles: [SplashParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .blur(radius: 2)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                animateParticles(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    private func generateParticles(in size: CGSize) {
        for _ in 0..<30 {
            particles.append(SplashParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 3...8),
                color: [Color.cyan, Color.blue, Color.purple, Color.pink].randomElement()!,
                opacity: Double.random(in: 0.2...0.5)
            ))
        }
    }
    
    private func animateParticles(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            for index in particles.indices {
                // Floating animation
                particles[index].position.y -= CGFloat.random(in: 0.3...1.0)
                particles[index].position.x += CGFloat.random(in: -0.5...0.5)
                
                // Wrap around
                if particles[index].position.y < 0 {
                    particles[index].position.y = size.height
                    particles[index].position.x = CGFloat.random(in: 0...size.width)
                }
                
                // Pulse opacity
                particles[index].opacity = Double.random(in: 0.2...0.5)
            }
        }
    }
}

struct SplashParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}

struct ModernSplashView_Previews: PreviewProvider {
    static var previews: some View {
        ModernSplashView(isActive: .constant(false))
    }
}
