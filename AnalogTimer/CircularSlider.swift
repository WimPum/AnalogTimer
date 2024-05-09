//
//  CircularSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/20.
//

import SwiftUI

struct CircularSlider: View {
    @Binding var controlValue: Double // 外部で
//    @GestureState private var dragLocation: CGPoint?
    @State private var handDrawPos: CGPoint = CGPoint(x: 0, y: 0)
    @State private var angleValue: Double = 0.0
    let config: Config
    var body: some View {
        //GeometryReader{ geometry in
            ZStack{
                Capsule() // つかむところ
                    .fill(config.color)
                    .frame(width: config.knobWidth, height: config.knobLength)
                    .padding(10) // paddingがあると掴みやすい
                    //.border(.white)
                    .offset(y: -(config.knobLength / 2 + config.tailLength)) // 初期状態
                    .rotationEffect(Angle.degrees(angleValue))
                    .gesture(DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
                        .onChanged({value in
                            changeAngle(location: value.location,
                                        ifSnap: true)
                        }))
                ClockHands(drawPos: handDrawPos)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .fill(config.color)
            }
            .onAppear{ // 開いた時点で針を表示
                updateAngle()
            }
            .onChange(of: controlValue) { _ in
                updateAngle()
            }
            .padding(10)
        //}.border(.yellow)
    }

    // 角度を変えるよう
    private func changeAngle(location: CGPoint, ifSnap: Bool){ // View内関数
        // ベクトル化
        let vector = CGVector(dx: location.x, dy: location.y)

        // 角度算出 //なんでベクトルにした？ knobの半径とpaddingを引きます
        let angle = atan2(config.knobLength / 2 + config.tailLength + 20 - vector.dy,
                          10 - vector.dx) - .pi / 2 // .pi/2は90度
        // 中心位置がどこか？GeometryReader
        if (ifSnap == true){
            let snappedAngle = angleSnapper(angle: angle, snapAmount: config.snapCount) // スナップ先の角度
            let correctedAngle = snappedAngle < 0 ? snappedAngle + 2 * .pi : snappedAngle // 範囲を0~2piにする radian
            let sliderValue = round(correctedAngle / (.pi * 2) * config.maxValue)// 今の角度/円
            self.controlValue = sliderValue
            self.angleValue = correctedAngle * 180 / .pi
            handDrawPos = CGPoint(x: config.tailLength * cos(correctedAngle - .pi / 2),
                                 y: config.tailLength * sin(correctedAngle - .pi / 2))
        } else {
            let correctedAngle = angle < 0 ? angle + 2 * .pi : angle // 範囲を0~2piにする radian
            let sliderValue = correctedAngle / (.pi * 2) * config.maxValue// 今の角度/円
            self.controlValue = sliderValue
            self.angleValue = correctedAngle * 180 / .pi
            handDrawPos = CGPoint(x: config.tailLength * cos(correctedAngle - .pi / 2),
                                 y: config.tailLength * sin(correctedAngle - .pi / 2))
            //print("touched \(location)")
            print("Center should be zero? \(location.x - 10), \(location.y - (config.knobLength / 2 + config.tailLength) + 20)")
            //print("\(viewSize.x / 2), \(viewSize.y / 2)")
        }
    }
    
    // 値が変わったりした時角度を更新
    private func updateAngle(){
        let angle = .pi * 2 / config.maxValue * controlValue
        let correctedAngle = angle < 0 ? angle + 2 * .pi : angle // 範囲を0~2piにする
        handDrawPos = CGPoint(x: config.tailLength * cos(correctedAngle - .pi / 2),
                              y: config.tailLength * sin(correctedAngle - .pi / 2))
        angleValue = correctedAngle * 180 / .pi // 表示された時に現在の値を反映させる
    }
}

func angleSnapper(angle: CGFloat, snapAmount: Int) -> CGFloat{ // 直したい角度と、スナップ点の数
    let angleDeg = angle / .pi * 180 // deg変換
    let unitAngle = CGFloat(360 / Float(snapAmount)) // やはりDegreesで OK
    let returnAngle = round(angleDeg / unitAngle) * unitAngle
    //print("angleDeg:\(angleDeg), unitangle:\(unitAngle), return:\(returnAngle), rad\(returnAngle * .pi / 180)")
    return returnAngle * .pi / 180
}

struct ClockTicks: View {
    let radius: CGFloat
    let tickCount: Int // 目盛りの総数
    let tickWidth: CGFloat // 目盛りの太さ
    let tickLength: CGFloat // 目盛りの長さ

    var body: some View {
        ZStack(){
            ForEach(0..<tickCount, id: \.self) { index in
                let angle = Double(index) / Double(tickCount) * 2 * .pi // 目盛りの角度
                
                // 目盛りを描画
                Rectangle()
                    .fill(Color.white)
                    .frame(width: tickWidth, height: tickLength)
                    .clipShape(Capsule())
                    .offset(x: 0, y: -radius) // 時計の中心からの距離
                    .rotationEffect(.radians(angle)) // 目盛りの位置を回転
            }
        }
    }
}

struct ClockHands: Shape {
    let drawPos: CGPoint
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x + drawPos.x,
                                 y: center.y + drawPos.y))
        print("ITSU\(CGPoint(x: center.x + drawPos.x, y: center.y + drawPos.y))")
        return path
    }
}

struct Config { // 位置とか設定
    let color: Color
    let minValue: CGFloat
    let maxValue: CGFloat
    let snapCount: Int // snapする数
    let knobLength: CGFloat // 長さ
    let knobWidth: CGFloat // 半径 あとで2倍する
    let tailLength: CGFloat // 針の先端の長さ
}

#Preview {
    PreviewClock()
}

