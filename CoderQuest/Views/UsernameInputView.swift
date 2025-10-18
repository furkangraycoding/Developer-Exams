import SwiftUI

struct UsernameInputView: View {
    @Binding var isActive: String
    @Binding var username: String
    @EnvironmentObject var globalViewModel: GlobalViewModel

    @State private var inputAreaOffset: CGFloat = -500
    @State private var inputAreaOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var showWelcomeText = false

    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.6), Color.cyan.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated particles
            RandomShapesView(shapesWithPositions: $globalViewModel.shapesWithPositions)
                .environmentObject(globalViewModel)
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo and Welcome Section
                VStack(spacing: 20) {
                    // Logo with glow effect
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.cyan.opacity(0.4), Color.clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 20)
                        
                        Image(.developer)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .shadow(color: .cyan.opacity(0.5), radius: 20)
                    }
                    .scaleEffect(logoScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: logoScale)
                    
                    if showWelcomeText {
                        VStack(spacing: 8) {
                            Text("Welcome to")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("CoderQuest")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.cyan, .purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Start your coding journey")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 40)
                
                Spacer()
                
                // Input Card
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose your username")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.cyan)
                                .font(.title3)
                            
                            TextField("Enter username", text: $username)
                                .font(.body)
                                .foregroundColor(.white)
                                .accentColor(.cyan)
                                .onChange(of: username) { newValue in
                                    if newValue.count > 16 {
                                        username = String(newValue.prefix(16))
                                    }
                                }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    
                    // Continue Button
                    Button(action: {
                        withAnimation(.spring()) {
                            globalViewModel.isActive = "AnaEkran"
                            if username.isEmpty {
                                username = "Player" + String(Int.random(in: 1000..<9999))
                            }
                            globalViewModel.username = username
                        }
                    }) {
                        HStack {
                            Text("Start Learning")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Skip button
                    Button(action: {
                        withAnimation(.spring()) {
                            username = "Guest" + String(Int.random(in: 100..<999))
                            globalViewModel.username = username
                            globalViewModel.isActive = "AnaEkran"
                        }
                    }) {
                        Text("Continue as Guest")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .underline()
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.5), .purple.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .cyan.opacity(0.2), radius: 20)
                )
                .padding(.horizontal, 30)
                .offset(y: inputAreaOffset)
                .opacity(inputAreaOpacity)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: inputAreaOffset)
                
                Spacer()
                
                // Footer
                Text("© 2025 CoderQuest • Learn. Practice. Master.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showWelcomeText = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    inputAreaOffset = 0
                    inputAreaOpacity = 1
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct UsernameInputView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameInputView(isActive: .constant(""), username: .constant(""))
            .environmentObject(GlobalViewModel()) // Assuming you have a GlobalViewModel in your environment
    }
}
