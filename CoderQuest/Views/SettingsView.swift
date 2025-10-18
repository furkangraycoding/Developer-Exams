import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("notifications") private var notifications = true
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.1, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // General settings
                        SettingsSection(title: "General") {
                            SettingsToggle(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                isOn: $soundEnabled,
                                color: .blue
                            )
                            
                            SettingsToggle(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Vibration",
                                isOn: $vibrationEnabled,
                                color: .purple
                            )
                            
                            SettingsToggle(
                                icon: "bell.fill",
                                title: "Notifications",
                                isOn: $notifications,
                                color: .orange
                            )
                        }
                        
                        // Appearance
                        SettingsSection(title: "Appearance") {
                            SettingsToggle(
                                icon: "moon.fill",
                                title: "Dark Mode",
                                isOn: $darkMode,
                                color: .indigo
                            )
                        }
                        
                        // About
                        SettingsSection(title: "About") {
                            SettingsButton(
                                icon: "info.circle.fill",
                                title: "Version",
                                value: "1.0.0",
                                color: .cyan
                            ) {}
                            
                            SettingsButton(
                                icon: "star.fill",
                                title: "Rate Us",
                                color: .yellow
                            ) {
                                // Open App Store rating
                            }
                            
                            SettingsButton(
                                icon: "envelope.fill",
                                title: "Contact Support",
                                color: .green
                            ) {
                                // Open email
                            }
                        }
                        
                        // Danger zone
                        SettingsSection(title: "Danger Zone") {
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.red)
                                        .frame(width: 40)
                                    
                                    Text("Reset All Progress")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("Are you sure you want to reset all your progress? This action cannot be undone.")
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func resetProgress() {
        // Reset UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Reset ProgressManager
        ProgressManager.shared.userProgress = UserProgress()
        ProgressManager.shared.saveProgress()
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 5)
            
            VStack(spacing: 8) {
                content
            }
        }
    }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    var value: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
