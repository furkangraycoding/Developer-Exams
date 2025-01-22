import SwiftUI

struct SteadyRandomShapesView: View {
    // List of shapes for display (only Circles as per your request)
    let shapes = [
            AnyView(Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
                        .frame(width: 60, height: 60)
                        .shadow(radius: 10)
                        .overlay(
                            Text("?")
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                        )
            ),
            AnyView(Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0.6)]), startPoint: .top, endPoint: .bottom))
                        .frame(width: 60, height: 60)
                        .shadow(radius: 10)
                        .overlay(
                            Text("?")
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                        )
            ),
        ]
    
    // State to store shapes with their positions
    @State private var shapesWithPositions: [(shape: AnyView, position: CGPoint)] = []
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    // Flag to track if shapes are initialized
    @State private var isInitialized = false
    
    // Constants for the pattern
    let baseNumShapes: Int = 8  // Number of shapes in the inner circle layer
    let maxLayers: Int = 9  // Number of circular layers (Increased to 9 layers)
    let paddingBetweenCircles: CGFloat = 70  // Space between the layers of circles
    let shapeSize: CGFloat = 50  // Fixed size of each shape

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Only show shapes after they are initialized
                if isInitialized {
                    ForEach(0..<shapesWithPositions.count, id: \.self) { index in
                        self.shapesWithPositions[index].shape
                            .position(self.shapesWithPositions[index].position)
                            .opacity(0.8)
                    }
                }
            }
            .onAppear {
                // Initialize the shapes and their positions when the view appears
                if !isInitialized {
                    initializeCircularPatterns(in: geometry.size)
                    globalViewModel.shapesWithPositions = self.shapesWithPositions
                }
            }
        }
    }
    
    // Function to initialize the circular pattern of shapes
    private func initializeCircularPatterns(in size: CGSize) {
        // Calculate the center of the view
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        var shapes: [(shape: AnyView, position: CGPoint)] = []
        
        // Loop through each layer and place shapes in a circle
        for layer in 0..<maxLayers {
            let radius = CGFloat(layer + 1) * (shapeSize + paddingBetweenCircles) // Increase radius for each layer
            
            // Calculate the number of shapes for this layer: Increase as layer index increases
            let numShapesInLayer = baseNumShapes + layer * 3 // More shapes in outer layers
            
            // Angle step between each shape
            let angleStep = 360.0 / Double(numShapesInLayer)
            
            // Loop through the number of shapes and place them evenly in the current circle layer
            for i in 0..<numShapesInLayer {
                // Calculate the angle for the current shape
                let angle = angleStep * Double(i)
                
                // Convert polar coordinates (radius, angle) to Cartesian coordinates (x, y)
                let xPos = centerX + radius * cos(Angle.degrees(angle).radians)
                let yPos = centerY + radius * sin(Angle.degrees(angle).radians)
                
                // Select a random shape for each position
                let shape = self.shapes.randomElement()!
                
                shapes.append((shape: shape, position: CGPoint(x: xPos, y: yPos)))
            }
        }
        
        self.shapesWithPositions = shapes
        self.isInitialized = true
    }
}

struct SteadyRandomShapesView_Previews: PreviewProvider {
    static var previews: some View {
        SteadyRandomShapesView()
            .environmentObject(GlobalViewModel())  // Provide your environment object if needed
    }
}
