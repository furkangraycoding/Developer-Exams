import SwiftUI
import Combine

struct SplashScreenView: View {
    @State private var displayedText: String = ""
    private let fullText = "CoderQuest"
    private let subtitle = "Master Programming, One Question at a Time"
    private let typingSpeed: TimeInterval = 0.085
    @State private var timer: Timer.TimerPublisher?
    @State private var index = 0
    
    @State private var navigateToMainScreen = false
    @State private var isAppearing = true
    @State private var showSubtitle = false
    @State private var cancellables: Set<AnyCancellable> = []
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
            .animation(.linear(duration: 3).repeatForever(autoreverses: true), value: displayedText)
            
            // Animated particles
            SteadyRandomShapesView()
                .opacity(0.4)
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
                    Text(displayedText)
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
            startTypingAnimation()
        }
        .onChange(of: navigateToMainScreen) { _ in
            if navigateToMainScreen {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    transitionToMainApp()
                }
            }
        }
    }
    
    // Start the typing animation
    private func startTypingAnimation() {
        // Create the timer manually and use onReceive to track its updates
        timer = Timer.publish(every: typingSpeed, on: .main, in: .common)
        
        // Use onReceive to listen for timer updates and update the displayed text
        timer?
            .autoconnect()
            .sink { _ in
                typeText()
            }
            .store(in: &cancellables)
    }
    
    // This will type out the text one character at a time
    private func typeText() {
        if index < fullText.count {
            let character = fullText[fullText.index(fullText.startIndex, offsetBy: index)]
            displayedText.append(character)
            index += 1
        } else {
            // Once all the text is typed, stop the timer
            timer?.connect().cancel()
            // Show subtitle
            withAnimation(.easeIn(duration: 0.5)) {
                showSubtitle = true
            }
            // Trigger the navigation to the next screen after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                navigateToMainScreen = true
            }
        }
    }
    
    // Trigger the navigation to the next screen
    private func transitionToMainApp() {
        globalViewModel.isActive = "Login"
    }
}
