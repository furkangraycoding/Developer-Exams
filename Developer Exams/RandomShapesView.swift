import SwiftUI

struct RandomShapesView: View {
    let shapes = [
        AnyView(Circle().fill(Color.green).frame(width: 50, height: 50)),
        AnyView(Circle().fill(Color.black).frame(width: 50, height: 50)),
        AnyView(Rectangle().fill(Color.green).frame(width: 60, height: 60)),
        AnyView(Rectangle().fill(Color.black).frame(width: 60, height: 60)),
        AnyView(Ellipse().fill(Color.black).frame(width: 100, height: 60)),
        AnyView(Ellipse().fill(Color.green).frame(width: 100, height: 60)),
        AnyView(RoundedRectangle(cornerRadius: 25).fill(Color.green).frame(width: 100, height: 60)),
        AnyView(RoundedRectangle(cornerRadius: 25).fill(Color.black).frame(width: 100, height: 60))
    ]
    
    @State private var animate: Bool = true  // Bind the animation state
    
    @State private var positions: [CGPoint] = Array(repeating: CGPoint(x: 0, y: 0), count: 36) // Random positions
    @State private var offsets: [CGSize] = Array(repeating: CGSize(width: 0, height: 0), count: 36) // Offsets for movement
    
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                self.shapes.randomElement()!
                    .rotationEffect(Angle.degrees(Double.random(in: 0..<360)))
                    .position(self.positions[index])
                    .offset(self.offsets[index])
                    .opacity(0.8)
                    .animation(animate ? .easeInOut(duration: 5).repeatForever(autoreverses: true) : nil, value: animate)
                    .onAppear {
                        // Generate initial random positions and offsets for each shape
                        self.positions[index] = CGPoint(x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                                                         y: CGFloat.random(in: 0..<UIScreen.main.bounds.height))
                        self.offsets[index] = CGSize(width: CGFloat.random(in: -50..<50), height: CGFloat.random(in: -50..<50))
                        
                        // Start animating the offsets periodically
                        withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                            self.offsets[index] = CGSize(width: CGFloat.random(in: -50..<50), height: CGFloat.random(in: -50..<50))
                        }
                    }
                    .onChange(of: animate) { newValue in
                        if newValue {
                            // Reset animation with new random offsets when `animate` is true
                            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                                self.offsets[index] = CGSize(width: CGFloat.random(in: -50..<50), height: CGFloat.random(in: -50..<50))
                            }
                        }
                    }
            }
        }
    }
}
