import SwiftUI

struct MenuView: View {
    @Binding var isMenuVisible: Bool
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    // New color palette using built-in SwiftUI colors
    let menuItems = [
        ("Swift", Color.purple),
        ("Java", Color.purple),
        ("Javascript", Color.purple),
        ("Ruby", Color.purple),
        ("Python", Color.purple),
        ("C#", Color.purple),
        ("Go", Color.purple),
        ("Solidty", Color.purple)
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // Soft gradient background with built-in colors
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0..<menuItems.count, id: \.self) { index in
                                Button(action: {
                                    withAnimation {
                                        GlobalViewModel.shared.chosenMenu = menuItems[index].0
                                        isMenuVisible = false // Hide the menu when a choice is made
                                    }
                                }) {
                                    Text(menuItems[index].0)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: (geometry.size.width - 60) / 2, height: (geometry.size.width - 60) / 2) // Making each button square
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [menuItems[index].1.opacity(0.6), menuItems[index].1]),
                                                           startPoint: .top, endPoint: .bottom)
                                        )
                                        .cornerRadius(20) // Apply corner radius to the background
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(menuItems[index].1, lineWidth: 4) // Apply border with corner radius
                                        )
                                        .shadow(radius: 10) // Add shadow for a more polished look
                                        .scaleEffect(isMenuVisible ? 1 : 0.95) // Subtle zoom-in effect
                                        .animation(.easeInOut(duration: 0.3), value: isMenuVisible) // Smooth animation
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

