//
//  CircularSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/20.
//

import SwiftUI

struct CircularSlider: View {
    @Binding var controlValue: Double // 外部で
    @State private var currentPos: CGPoint = CGPoint(x: 0, y: 0)
    @State private var angleValue: Double = 0.0
    let config: Config
    var body: some View {
        ZStack{
            VStack{
                ZStack{
//                    Circle() // 線
//                        .trim(from: 0.0, to: controlValue / config.totalValue)
//                        .stroke(config.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
//                        .rotationEffect(.degrees(-90))
//                        .frame(width: config.radius * 2, height: config.radius * 2)
                    Circle() // つかむところ
                        .fill(config.color)
                        .frame(width: config.knobRadius * 2, height: config.knobRadius * 2)
                        .padding(10) // paddingがあると掴みやすい
                        .offset(y: -config.radius) // 初期状態
                        .rotationEffect(Angle.degrees(angleValue))
                        .gesture(DragGesture(minimumDistance: 0.0)
                            .onChanged({value in
                                changeAngleSnap(location: value.location)
                            }))
                    clockHands(drawPos: currentPos)
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .fill(config.color)
                }
                .onAppear{ // 開いた時点で針を表示
                    let angle = .pi * 2 / config.maxValue * controlValue
                    let correctedAngle = angle < 0 ? angle + 2 * .pi : angle // 範囲を0~2piにする
                    currentPos = CGPoint(x: (config.radius + config.tipLength) * cos(correctedAngle - .pi / 2),
                                         y: (config.radius + config.tipLength) * sin(correctedAngle - .pi / 2))
                }
            }.padding(10)
        }
    }
//    private func changeAngle(location: CGPoint){ // View内関数
//        // ベクトル化
//        let vector = CGVector(dx: location.x, dy: location.y)
//        // 角度算出 //なんでベクトルにした？ knobの半径とpaddingを引きます
//        let angle = atan2(vector.dy - (config.knobRadius + 10), 
//                          vector.dx - (config.knobRadius + 10)) + .pi / 2 // .pi/2は90度
//        let correctedAngle = angle < 0 ? angle + 2 * .pi : angle // 範囲を0~2piにする radian
//        let sliderValue = correctedAngle / (.pi * 2) * config.maxValue// 今の角度/円
//        self.controlValue = sliderValue
//        self.angleValue = correctedAngle * 180 / .pi
//        currentPos = CGPoint(x: (config.radius + config.tipLength) * cos(correctedAngle - .pi / 2),
//                             y: (config.radius + config.tipLength) * sin(correctedAngle - .pi / 2))
//    }
    private func changeAngleSnap(location: CGPoint){ // View内関数
        // ベクトル化
        let vector = CGVector(dx: location.x, dy: location.y)
        // 角度算出 //なんでベクトルにした？ knobの半径とpaddingを引きます
        let angle = atan2(vector.dy - (config.knobRadius + 10),
                          vector.dx - (config.knobRadius + 10)) + .pi / 2 // .pi/2は90度
        let snappedAngle = angleSnapper(angle: angle, snapAmount: config.snapCount) // スナップ先の角度
        let correctedAngle = snappedAngle < 0 ? snappedAngle + 2 * .pi : snappedAngle // 範囲を0~2piにする radian
        let sliderValue = round(correctedAngle / (.pi * 2) * config.maxValue)// 今の角度/円
        //print("sliderVal:\(sliderValue)")
        self.controlValue = sliderValue
        self.angleValue = correctedAngle * 180 / .pi
        currentPos = CGPoint(x: (config.radius + config.tipLength) * cos(correctedAngle - .pi / 2),
                             y: (config.radius + config.tipLength) * sin(correctedAngle - .pi / 2))
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

struct clockHands: Shape {
    let drawPos: CGPoint
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x + drawPos.x,
                                 y: center.y + drawPos.y))
        return path
    }
}

struct Config { // 位置とか設定
    let color: Color
    let minValue: CGFloat
    let maxValue: CGFloat
    let snapCount: Int // snapする数
    let knobRadius: CGFloat // 半径 あとで2倍する
    let radius: CGFloat
    let tipLength: CGFloat // 針の先端の長さ
}

#Preview {
    PreviewSlider()
//    ClockTicks(radius: 120, tickCount: 12, tickWidth: 7, tickLength: 20)
}
