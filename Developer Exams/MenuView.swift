import SwiftUI

struct MenuView: View {// Binding to chosenMenu from parent view
    @Binding var isMenuVisible: Bool
    @EnvironmentObject var globalViewModel: GlobalViewModel
    let menuItems = [
        ("Swift", Color.red),
        ("Menu 2", Color.blue),
        ("Menu 3", Color.green),
        ("Menu 4", Color.orange),
        ("Menu 5", Color.purple),
        ("Menu 6", Color.yellow),
        ("Menu 7", Color.pink),
        ("Menu 8", Color.teal)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                VStack {
                    // Scrollable grid of buttons
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(0..<8) { index in
                                Button(action: {
                                    globalViewModel.chosenMenu = menuItems[index].0
                                    isMenuVisible = false // Hide the menu when a choice is made
                                }) {
                                    Text(menuItems[index].0)
                                        .font(.title2)
                                        .foregroundColor(menuItems[index].1)
                                        .frame(width: geometry.size.width / 3, height: geometry.size.width / 3) // Making each button square
                                        .background(Color.black)
                                        .cornerRadius(15) // Apply corner radius to the background
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(menuItems[index].1, lineWidth: 5) // Apply border with corner radius
                                        )
                                }
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .frame(maxWidth: .infinity) // Make sure it takes up the full width
                }
                .navigationTitle("Menu Selector")
                .navigationBarTitleDisplayMode(.inline)
            }
            }
        }
    }}
