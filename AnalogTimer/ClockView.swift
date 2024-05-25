//
//  PreviewSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/28.
//

import SwiftUI

struct ClockFace: View{ // 実験用View
    // main
    @State private var minControlValue: Double = 0.0 // Minute:Secondの順番を守る
    @State private var secControlValue: Double = 0.0
    
    // clock revolution detector
    @State private var secPreviousAngle: Double? = 0.0 // ドラッグ開始時の角度を保持する
    @State private var secAngleValue: Double = 0.0
    @State private var minPreviousAngle: Double? = 0.0 // ドラッグ開始時の角度を保持する
    @State private var minAngleValue: Double = 0.0

    let minConfig = Config(color: Color.green,
                           minValue: 0, maxValue: 60, snapCount: 60,
                           knobLength: 90, knobWidth: 11, tailLength: 23)
    let secConfig = Config(color: .orange,
                           minValue: 0, maxValue: 60, snapCount: 60,
                           knobLength: 135, knobWidth: 9, tailLength: 23)
    
    @State private var passCount: Int = 0 // 通過カウント
    var body: some View{
        ZStack(){
            Text("\(String(format: "%02d", Int(minControlValue))):\(String(format: "%02d", Int(secControlValue)))")
                .font(.system(size: CGFloat(80), weight: .light, design: .default))
                .foregroundStyle(Color.white)
                .padding()
            ClockTicks(radius: 170, tickCount: 60, tickWidth: 6, tickLength: 12) // 小さい方
            ClockTicks(radius: 161, tickCount: 12, tickWidth: 10, tickLength: 35) // 大きい方
            
            CircularSlider(controlValue: $minControlValue, // Minute 秒針とできるだけ共通で実装
                           angleValue: $minAngleValue,
                           config: minConfig)
                .rotationEffect(Angle(degrees: 6 * (secControlValue / 60))) // 秒針が回ったらこっちも回転
                .gesture(
                    DragGesture(minimumDistance: 0.0)
                        .onChanged({value in
                            let angle = angleSnapper(degAngle: returnDegAngle(config: minConfig, location: value.location),
                                                     snapAmount: 60)
                            if let previousAngle = minPreviousAngle{
                                var angleChange = angle - previousAngle // 変わった角度の大きさ
                                
                                // formatter
                                if angleChange > 180{ //
                                    angleChange -= 360
                                } else if angleChange < -180{
                                    angleChange += 360
                                }
                                minAngleValue += angleChange
                                minControlValue = round(angle / 360 * minConfig.maxValue)// 今の角度/円 snapped
                            }
                            minPreviousAngle = angle
                        })
                        .onEnded { _ in
                            minPreviousAngle = nil
                        }
                    )

            CircularSlider(controlValue: $secControlValue, // Second
                           angleValue: $secAngleValue,
                           config: secConfig)
                .gesture(
                    DragGesture(minimumDistance: 0.0)
                        .onChanged({value in
                            let angle = angleSnapper(degAngle: returnDegAngle(config: secConfig, location: value.location),
                                                     snapAmount: 60)
                            if let previousAngle = secPreviousAngle{
                                var angleChange = angle - previousAngle // 変わった角度の大きさ
                                
                                // formatter
                                if angleChange > 180{ //
                                    angleChange -= 360
                                } else if angleChange < -180{
                                    angleChange += 360
                                }
                                secAngleValue += angleChange
                                minAngleValue += floor(self.secAngleValue / 360) * 6
                                minAngleValue = angleFormatter(degAngle: minAngleValue)

                                secControlValue = round(angle / 360 * secConfig.maxValue)// 今の角度/円 snapped
                                //minControlValue = round(minAngleValue / 360 * minConfig.maxValue) // 今の角度/円
                                minControlValue = angle2value(config: minConfig, degAngle: minAngleValue)
                                print("\(minAngleValue), \(secAngleValue), \(angle)")
//
                            }
                            secPreviousAngle = angle
                        })
                        .onEnded { _ in
                            secPreviousAngle = nil
                        }
                    )
            
            
            Circle() // あとで針の見た目を変えた時に変更
                .fill(.black)
                .frame(width: 20, height: 20)
            Circle() // あとで針の見た目を変えた時に変更
                .fill(.orange)
                .frame(width: 8, height: 8)
        }
    }
}

struct PreviewClock: View {
    var body: some View {
        ZStack(){
            LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ClockFace()
        }
    }
}

#Preview {
    PreviewClock()
}
