import SwiftUI

extension Color {
    // Custom app colors
    static let appPrimary = Color.cyan
    static let appSecondary = Color.blue
    static let appAccent = Color.purple
    
    // Background gradients
    static let darkGradient1 = Color(red: 0.05, green: 0.05, blue: 0.15)
    static let darkGradient2 = Color(red: 0.1, green: 0.05, blue: 0.2)
    static let darkGradient3 = Color(red: 0.15, green: 0.1, blue: 0.25)
    
    // Card backgrounds
    static let cardBackground = Color.white.opacity(0.05)
    static let cardBorder = Color.white.opacity(0.1)
    
    // Success/Error colors
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange
    static let info = Color.blue
}

extension LinearGradient {
    static var appBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.darkGradient1,
                Color.darkGradient2,
                Color.darkGradient3
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.cyan, Color.blue]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var successGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.cyan]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var warningGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.yellow]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// View modifiers for consistent styling
extension View {
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .background(LinearGradient.primaryGradient)
            .cornerRadius(15)
            .shadow(color: Color.appPrimary.opacity(0.3), radius: 10)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.cardBorder, lineWidth: 1)
                    )
            )
    }
}
