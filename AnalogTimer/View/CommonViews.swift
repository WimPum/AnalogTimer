//
//  CircularSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/20.
//

import SwiftUI

//MARK: Views

// ここでやることは最低限にする
// angleValueは外から変更できるようにBindingにしてある
struct ClockHand: View {
    @Binding var angleValue: CGFloat    // 今の角度
    var color: Color
    let config: Config
    var body: some View {
        ZStack{
            // つかむところ
            Capsule()
                .fill(color)
                .frame(width: config.knobWidth, height: config.knobLength)
                .padding(15) // paddingがあると掴みやすい
                .offset(y: -(config.knobLength / 2 + config.tailLength)) // 初期状態
            ClockTail(length: config.tailLength)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .fill(color)
        }
        .frame(width: (config.tailLength + config.knobLength) * 2,
               height: (config.tailLength + config.knobLength) * 2)
        .rotationEffect(Angle.degrees(angleValue/config.divisor)) // 回転を遅くする
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

struct Config { // 位置とか設定
    let divisor: CGFloat // 分針は回転が60倍遅くなる だから60で割る
    let snapCount: Int // snapする数
    let knobLength: CGFloat // 長さ
    let knobWidth: CGFloat // 半径 あとで2倍する
    let tailLength: CGFloat // 針の先端の長さ
}
