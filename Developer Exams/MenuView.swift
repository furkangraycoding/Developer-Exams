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
                                        .foregroundColor(.white)
                                        .frame(width: geometry.size.width / Double(6/2), height: geometry.size.width / Double(12/4)) // Making each button square
                                        .background(menuItems[index].1)
                                        .cornerRadius(15)
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
    }}
