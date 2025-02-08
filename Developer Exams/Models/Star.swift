import SwiftUI
 
struct Star: Shape {
    var points: Double = 5
    var depth: Double = 0.5
     
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(points, depth) }
        set {
            points = newValue.first
            depth = newValue.second
        }
    }
     
    func path(in rect: CGRect) -> Path {
        // Yıldızın merkezini ekranın tam ortasında tutmaya devam ediyoruz
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)  // Yıldız merkezini ekranın ortasında tut
        let angle = Double.pi / points
        var path = Path()
        var startPoint = CGPoint(x: 0, y: 0)
         
        // Yıldızın dış çapını daha küçük yapıyoruz
        let outerRadius = (min(rect.width, rect.height) / 2)  // Ekranın kısa kenarının dörtte biri kadar
        let innerRadius = (outerRadius * (1 - depth)) / 2   // İç çapı da daha küçük yapıyoruz

        // Dış çapı ve iç çapı küçültüp, kapladığı alanı azaltıyoruz.
        // Burada min() fonksiyonu ile hem en kısa kenar üzerinden çapları hesaplıyoruz.

        let maxCorners = Int(points * 2)
         
        for corner in 0..<maxCorners {
            let radius = (corner % 2) == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(Double(corner) * angle)) * CGFloat(radius)
            let y = center.y + CGFloat(sin(Double(corner) * angle)) * CGFloat(radius)
            let point = CGPoint(x: x, y: y)
             
            if corner == 0 {
                startPoint = point
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
             
            if corner == (maxCorners - 1) {
                path.addLine(to: startPoint)
            }
        }
         
        return path
    }
}
