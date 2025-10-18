import SwiftUI
import Combine

struct SplashScreenView: View {
    private let fullText = "CoderQuest"
    private let subtitle = "Master Programming, One Question at a Time"
    
    @State private var navigateToMainScreen = false
    @State private var isAppearing = true
    @State private var showSubtitle = false
    @Binding var isActive : String
    @EnvironmentObject var globalViewModel: GlobalViewModel

    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.6), Color.cyan.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Logo Animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.cyan.opacity(0.6), Color.purple.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 20)
                        .opacity(isAppearing ? 0 : 0.8)
                    
                    // Logo
                    Image(.developer)
                        .resizable()
                        .frame(width: 250, height: 250)
                        .foregroundColor(.cyan)
                        .opacity(navigateToMainScreen ? 0 : 1)
                        .scaleEffect(isAppearing ? 0.3 : 1)
                        .rotationEffect(.degrees(navigateToMainScreen ? 360 : 0))
                        .offset(y: navigateToMainScreen ? -250 : 0)
                        .shadow(color: .cyan.opacity(0.5), radius: 20)
                }
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isAppearing)
                .animation(.easeInOut(duration: 1.2), value: navigateToMainScreen)
                .onAppear {
                    withAnimation {
                        isAppearing = false
                    }
                }
                
                // Title
                VStack(spacing: 10) {
                    Text(fullText)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 10)
                    
                    if showSubtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding()

                Spacer()
                
                // Loading indicator
                if !navigateToMainScreen {
                    VStack(spacing: 15) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                            .scaleEffect(1.2)
                        
                        Text("Loading your adventure...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            // Show subtitle after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showSubtitle = true
                }
            }
            
            // Navigate after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                navigateToMainScreen = true
            }
        }
        .onChange(of: navigateToMainScreen) { _ in
            if navigateToMainScreen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    transitionToMainApp()
                }
            }
        }
    }
    
    // Trigger the navigation to the next screen
    private func transitionToMainApp() {
        globalViewModel.isActive = "Login"
    }
}
