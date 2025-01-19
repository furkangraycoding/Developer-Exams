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
                .ignoresSafeArea()

            VStack {
                // App Branding (Logo + App Title)
                HStack {
                    Image(systemName: "app.fill") // Placeholder for app logo, replace as needed
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.mint)
                        .background(.purple)
                    Text("Magnetic Minds App")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange) // Purple text for the app title
                        .padding(.leading, 5)
                }
                .padding(.top, 40)

                Spacer()

                // Input Area (Username Field) with animation
                VStack {
                    Text("Enter Your Username")
                        .fontWeight(.semibold)
                        .font(.title)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)

                    TextField("Your username...", text: $globalViewModel.username)
                        .padding()
                        .background(.orange)
                        .foregroundColor(.black)// Soft gray background for input field
                        .cornerRadius(15)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 30)
                        .italic()

                    // Button Area
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            globalViewModel.isActive = "AnaEkran"
                        }
                    }) {
                        Text("Continue")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.8)) // Bold orange for button
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                .background(Color.orange.opacity(0.8)) // Semi-transparent black background
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
                Text("@Copyrights MagneticMindsApp 2024 - 2025")
                    .font(.subheadline)
                    .foregroundColor(.orange.opacity(0.8)) // Subtle footer text color
                    .padding(.bottom, 20)
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
