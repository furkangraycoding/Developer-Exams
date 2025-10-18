import SwiftUI

struct ModernSplashView: View {
    @Binding var showSplash: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
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
            print("⏰ Splash timer started - will transition in 2 seconds")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                print("🚀 Transitioning to main menu...")
                print("🔄 Setting showSplash to false")
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
                print("✅ showSplash is now: \(showSplash)")
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
    }
}

struct ModernSplashView_Previews: PreviewProvider {
    static var previews: some View {
        ModernSplashView(showSplash: .constant(true))
    }
}
