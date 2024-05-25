//
//  CircularSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/20.
//

import SwiftUI

struct CircularSlider: View {
    @Binding var controlValue: Double   // 外部の値を編集
    @Binding var angleValue: Double     // 今の角度
    let config: Config
    
    var body: some View {
        ZStack{
            Capsule() // つかむところ
                .fill(config.color)
                .frame(width: config.knobWidth, height: config.knobLength)
                .padding(10) // paddingがあると掴みやすい
                .offset(y: -(config.knobLength / 2 + config.tailLength)) // 初期状態
            ClockTail(length: config.tailLength)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .fill(config.color)
        }
        .frame(width: (config.tailLength + config.knobLength) * 2,
               height: (config.tailLength + config.knobLength) * 2)
        .rotationEffect(Angle.degrees(angleValue))
        .onAppear{ // 開いた時点で針を表示
            updateAngle()
        }
        .onChange(of: controlValue) { _ in
            updateAngle()
        }
        
    }
    
    // 値が変わったりした時角度を更新
    private func updateAngle(){ // degrees
        let angle = 360 / config.maxValue * controlValue
        let correctedAngle = angleFormatter(degAngle: angle)
        angleValue = correctedAngle  // 表示された時に現在の値を反映させる
    }
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

struct ClockTail: Shape {
    let length: CGFloat
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x,
                                 y: center.y - length))
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

//#Preview {
//    PreviewClock()
//}

