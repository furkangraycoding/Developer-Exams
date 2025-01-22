import SwiftUI

struct RandomShapesView: View {
    // List of shapes for display
    // Binding to the parent view's shapes and positions
    @Binding var shapesWithPositions: [(shape: AnyView, position: CGPoint)]
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    // State to track if initialization has occurred
    @State private var isInitialized = false
    @State private var rotation: Double = 0  // Rotation for shapes
    @State private var questionRotation: Double = 360  // Rotation for "?" text (opposite direction)
    
    var body: some View {
        ZStack {
            // Show shapes with their positions from the binding variable
            ForEach(0..<shapesWithPositions.count, id: \.self) { index in
                self.shapesWithPositions[index].shape
                    .position(self.shapesWithPositions[index].position)
                    .rotationEffect(Angle.degrees(rotation)) // Rotation for shapes
                    .opacity(0.8)
                    .overlay(
                        Text("?")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .rotationEffect(Angle.degrees(questionRotation)) // Opposite rotation for "?"
                    )
            }
        }
        .onAppear {
            // Initialize shapes and positions when the view appears
            startRotationCycle()
        }
    }

    
    // Start rotating the shapes and "?" text in opposite directions
    private func startRotationCycle() {
        // Rotate shapes clockwise (slower)
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: true)) {
            self.rotation += 360
        }
        
        // Rotate "?" counter-clockwise (opposite direction, slower)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: true)) {
                self.questionRotation -= 360
            }
        }
    }
}

