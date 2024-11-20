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
    let config: HandConfig
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .fill(color)
                .frame(width: config.knobWidth, height: config.knobLength)
                .padding(15) // paddingがあると掴みやすい
                .offset(y: -(config.knobLength / 2 + config.tailLength)) // 初期状態
            ClockTail(length: config.tailLength)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .fill(color)
        }
        .frame(width:  (config.tailLength + config.knobLength) * 2,
               height: (config.tailLength + config.knobLength) * 2)
        .rotationEffect(Angle.degrees(angleValue/config.divisor)) // 回転を遅くする なんでここにrotationEffect？
    }
}

struct SecondHand: View { // 秒針 (中古ではない)
    @Binding var angleValue: CGFloat    // 今の角度
    var color: Color
    let config: HandConfig
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: config.cornerRadius)       // つかむところ
                .fill(color)
                .frame(width: config.knobWidth, height: config.knobLength)
                .padding(15) // paddingがあると掴みやすい
                .offset(y: -(config.knobLength / 2 - config.tailLength)) // 初期状態
        }
        .frame(width:  (config.knobLength - config.tailLength) * 2,
               height: (config.knobLength - config.tailLength) * 2)
        .rotationEffect(Angle.degrees(angleValue/config.divisor))
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
    let config: TickConfig
    var body: some View {
        ZStack(){
            ForEach(0..<config.tickCount, id: \.self) { index in
                let angle = Double(index) / Double(config.tickCount) * 2 * .pi // 目盛りの角度
                Rectangle()     // 目盛りを描画
                    .fill(Color.white)
                    .frame(width: config.tickWidth, height: config.tickLength)
                    .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius)) // (cornerRadius: config.tickWidth/2)
                    .offset(x: 0, y: -(config.radius-config.tickLength/2)) // 時計の中心からの距離
                    .rotationEffect(.radians(angle)) // 目盛りの位置を回転
            }
        }
        .frame(width:  config.radius * 2,
               height: config.radius * 2,
               alignment: .center)
    }
}

struct CircleNumber: View {
    let config: RadiConfig
    var body: some View {
        ZStack(){
            ForEach(0..<config.count, id: \.self) { index in
                let angleUnit = .pi * 2 / Double(config.count)
                let angle = Double(index) * angleUnit // 目盛りの角度
                Text(String(12/config.count*(index+1))) // 文字盤の数字
                    .fontMedium(size: config.fontSize)
                    .frame(width: config.fontSize*2, height: config.fontSize*2)
                    .offset(x: 0, y: -(config.radius-config.fontSize/2)) // 時計の中心からの距離
                    .rotationEffect(.radians(angle+angleUnit)) // 目盛りの位置を回転
            }
        }
        .frame(width:  config.radius * 2,
               height: config.radius * 2,
               alignment: .center)
    }
}

struct RadialNumber: View {
    let config: RadiConfig
    var body: some View {
        ZStack(){
            ForEach(0..<config.count, id: \.self) { index in
                let angleUnit = .pi * 2 / Double(config.count)
                let angle = Double(index) * angleUnit // 目盛りの角度
                let radius = config.radius-config.fontSize/2
                Text(String(12/config.count*(index+1))) // 文字盤の数字
                    .fontMedium(size: config.fontSize)
                    .frame(width: config.fontSize*2, height: config.fontSize*2)
                    .offset(x: sin(angle+angleUnit) * radius, y: -cos(angle+angleUnit) * radius) // 時計の中心からの距離
            }
        }
        .frame(width:  config.radius * 2,
               height: config.radius * 2,
               alignment: .center)
    }
}

struct HandConfig { // 位置とか設定
    let knobWidth:  CGFloat  // 幅
    let knobLength: CGFloat // 長さ
    let tailLength: CGFloat // 針の先端の長さ
    let snapCount: Int      // snap回数
    let cornerRadius: CGFloat
    let divisor: CGFloat // 分針は回転が60倍遅くなる だから60で割る
}

struct TickConfig {
    let tickWidth:  CGFloat  // 目盛りの太さ
    let tickLength: CGFloat // 目盛りの長さ
    let radius: CGFloat
    let tickCount: Int // 目盛りの総数
    let cornerRadius: CGFloat // 目盛の角丸度
}

struct RadiConfig {
    let fontSize: CGFloat
    let radius: CGFloat
    let count: Int // 目盛りの総数
}

#Preview {
//    let tickConfig = TickConfig(tickWidth: 12, tickLength: 34, radius: 161, tickCount: 12, cornerRadius: 16)
//    ClockTicks(config: tickConfig)
//        .border(.red, width: 5)
//    RadialNumber(config: RadiConfig(fontSize: 40, radius: 161, count: 12))
    @StateObject var timers = TimerLogic()
    let secConfig = HandConfig(knobWidth: 6,  knobLength: 210, tailLength: 30, snapCount: 60, cornerRadius: 3, divisor: 1)
    SecondHand(angleValue: $timers.angleValue, color: .red, config: secConfig)
}
