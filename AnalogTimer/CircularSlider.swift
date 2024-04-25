//
//  CircularSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/20.
//

import SwiftUI

struct CircularSlider: View {
    @Binding var controlValue: Double // 外部で
    @State private var angleValue: Double = 0.0
    let config: Config
    var body: some View {
        ZStack{
            VStack{
                ZStack{
                    Circle() // 線
                        .trim(from: 0.0, to: controlValue / config.totalValue)
                        .stroke(config.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: config.radius * 2, height: config.radius * 2)
                    Circle() // つかむところ
                        .fill(config.color)
                        .frame(width: config.knobRadius * 2, height: config.knobRadius * 2)
                        .padding(10) // paddingがあると掴みやすい
                        .offset(y: -config.radius) // 初期状態
                        .rotationEffect(Angle.degrees(angleValue))
                        .gesture(DragGesture(minimumDistance: 0.0)
                            .onChanged({value in
                                changeAngle(location: value.location)
                            }))
                }
//                Slider(value: $controlValue, in: 0.0...59.9)
//                    .onChange(of: controlValue, {
//                        let angleRadian =  controlValue * (.pi * 2) / config.totalValue
//                        self.angleValue = angleRadian * 180 / .pi
//                    })
            }.padding(10)
        }
    }
    private func changeAngle(location: CGPoint){ // View内関数
        // ベクトル化
        let vector = CGVector(dx: location.x, dy: location.y)
        // 角度算出 //なんでベクトルにした？ knobの半径とpaddingを引きます
        let angle = atan2(vector.dy - (config.knobRadius + 10), 
                          vector.dx - (config.knobRadius + 10)) + .pi / 2 // .pi/2は90度
        let correctedAngle = angle < 0 ? angle + 2 * .pi : angle
        let sliderValue = correctedAngle / (.pi * 2) * config.totalValue// 今の角度/円
        self.controlValue = sliderValue
        self.angleValue = correctedAngle * 180 / .pi
    }
}

struct Config { // 位置とか設定
    let color: Color
    let minValue: CGFloat
    let maxValue: CGFloat
    let totalValue: CGFloat // maxValue???
    let knobRadius: CGFloat // 半径 あとで2倍する
    let radius: CGFloat
}

struct PreviewSlider: View{
    @State private var controlValueInner: Double = 0.0
    @State private var controlValueOuter: Double = 0.0
    var body: some View{
        ZStack(){
            LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            CircularSlider(controlValue: $controlValueInner, // second
                           config: Config(color: Color.green,
                                          minValue: 0, maxValue: 60, totalValue: 60,
                                          knobRadius: 15, radius: 120))
            CircularSlider(controlValue: $controlValueOuter, // minute
                           config: Config(color: Color.orange,
                                          minValue: 0, maxValue: 60, totalValue: 60,
                                          knobRadius: 15, radius: 160))
            
//            Text("\(String(format: "%02d", Int(controlValueInner)))").foregroundStyle(Color.white)
//                .font(.system(size: CGFloat(100), weight: .light, design: .default))
            Text("\(String(format: "%02d", Int(controlValueOuter))):\(String(format: "%02d", Int(controlValueInner)))")
                .font(.system(size: CGFloat(80), weight: .light, design: .default))
                .foregroundStyle(Color.white)
                .padding()
        }
    }
}

#Preview {
    PreviewSlider()
}
