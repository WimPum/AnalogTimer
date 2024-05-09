import SwiftUI

struct ContentView: View {
    @State var angle: Double = 0.5
    
    let width: CGFloat = 250
    let height: CGFloat = 250

    let beginAngle: Double = 0.0
    let endAngle: Double = 1.0
    let minimumValue: Double = 0
    let maximumValue: Double = 100
    
    var value: Int {
        let percent = (self.angle - self.beginAngle) / (self.endAngle - self.beginAngle)
                
        var value = (maximumValue - minimumValue) * percent + minimumValue
        
        if value < minimumValue {
            value = minimumValue
        }
        
        if maximumValue < value {
            value = maximumValue
        }
        
        return Int(value)
    }
        
    func onChanged(value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        // 中央からタップ位置までの距離
        let distanceX: Double = self.width  / 2 - vector.dx
        let distanceY: Double = self.height / 2 - vector.dy

        // Circle()の中央からタップ位置のラジアンアークタンジェント2を求める
        let radians: Double = atan2(distanceX, distanceY)
        
        let center: Double = (self.endAngle + self.beginAngle) / 2.0
        
        let angle: Double = center - (radians / (2.0 * .pi))
        
        // アニメーションをつけているが、つけなくてももちろん問題ない
        withAnimation(Animation.linear(duration: 0.1)){
            self.angle = self.endAngle < angle ? self.endAngle : angle
        }
    }
    
    var body: some View {
        ZStack {
            Text(String(self.value))
            Circle()
                .trim(from: self.beginAngle, to: self.endAngle)
                .stroke(Color.black, lineWidth: 20)
                .frame(width: self.width, height: self.height)
                .rotationEffect(.init(degrees: 90))
                .gesture(
                    DragGesture().onChanged(self.onChanged(value:))
                )
            Circle()
                .trim(from: self.beginAngle, to: self.angle)
                .stroke(Color.orange, lineWidth: 20)
                .frame(width: self.width, height: self.height)
                .rotationEffect(.init(degrees: 90))
                .gesture(
                    DragGesture().onChanged(self.onChanged(value:))
                )
        }
    }
}

#Preview {
    ContentView()
}
