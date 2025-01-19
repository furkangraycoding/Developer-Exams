import SwiftUI

struct UsernameInputView: View {
    @Binding var isActive: String
    @Binding var username: String
    @EnvironmentObject var globalViewModel: GlobalViewModel

    @State private var inputAreaOffset: CGFloat = -500  // Start above the screen
    @State private var inputAreaOpacity: Double = 0      // Start invisible

    var body: some View {
        ZStack {
            // Primary background is black
            Color.black
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Image(.developer) // Placeholder for app logo, replace as needed
                            .resizable()
                            .frame(width: .infinity, height: geometry.size.height / 3)
                            .foregroundColor(.mint)
                            .background(.black)
                    }
                    .padding(.top, 10)
                    
                    // Input Area (Username Field) with animation
                    VStack {
                        
                        TextField("Your username...", text: $username)
                            .padding()
                            .background(.green)
                            .foregroundColor(.black)// Soft gray background for input field
                            .cornerRadius(15)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 30)
                            .italic()
                        
                        // Button Area
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                globalViewModel.isActive = "AnaEkran"
                                globalViewModel.username = username
                            }
                        }) {
                            Text("Continue")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8)) // Bold green for button
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .padding(.top, 20)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(40)
                    .background(Color.black.opacity(0.8)) // Semi-transparent black background
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .offset(y: inputAreaOffset)  // Apply the offset for animation
                    .opacity(inputAreaOpacity)   // Apply opacity for fade-in effect
                    .animation(.easeOut(duration: 0.8), value: inputAreaOffset) // Animate the offset
                    .onAppear {
                        // Start the animation when the view appears
                        withAnimation(.easeOut(duration: 0.8)) {
                            inputAreaOffset = 0      // Move the input area to its original position
                            inputAreaOpacity = 1     // Fade in the input area
                        }
                    }
                    
                    Spacer()
                    
                    // Footer with Copyright Text
                    Text(" @Copyrights MagneticMindsApp 2025 ")
                        .font(.subheadline)
                        .foregroundColor(.green.opacity(0.3)) // Subtle footer text color
                        .padding(.bottom, 20)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isActive)
        .navigationBarHidden(true) // Hide navigation bar
    }
}

struct UsernameInputView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameInputView(isActive: .constant(""), username: .constant(""))
            .environmentObject(GlobalViewModel()) // Assuming you have a GlobalViewModel in your environment
    }
}
