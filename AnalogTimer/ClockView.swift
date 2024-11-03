//
//  PreviewSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/28.
//

import SwiftUI

// ClockView
struct ClockView: View{
    // Values
    @Binding var angleValue: CGFloat     // 角度の値 360°を超えていく 1秒は6° つまりangleValue/6=seconds
    @State private var previousAngle: CGFloat? = 0.0    // ドラッグ開始時の角度を保持する すごいやつ
    var isSnappy: Bool = false           // スナップ有無
    var isTimerRunning: Bool
    let secConfig = Config(color: .orange, divisor: 1, snapCount: 60, knobLength: 135, knobWidth: 9, tailLength: 23) // color_mutable???
    let minConfig = Config(color: .green, divisor: 60, snapCount: 60, knobLength: 90, knobWidth: 11, tailLength: 23)
    var body: some View{
        ZStack(){
            Text("\(String(format: "%02d",Int(angleValue/360))):\(String(format: "%02d",Int((angleValue/6).truncatingRemainder(dividingBy: 60))))")
                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .light))) // 等幅モード！！
                .foregroundStyle(Color.white)
                .padding()
            ClockTicks(radius: 170, tickCount: 60, tickWidth: 6, tickLength: 12) // 小さい方
            ClockTicks(radius: 161, tickCount: 12, tickWidth: 10, tickLength: 35) // 目盛り
            // 長針　秒針のこと
            ClockHand(angleValue: $angleValue, config: secConfig)
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged({value in
                            if isTimerRunning == false{
                                let dragAngle = angleSnapper(degAngle: returnDegAngle(config: secConfig, location: value.location),
                                                             snapAmount: secConfig.snapCount, enableSnap: isSnappy)
                                if let previousAngle = previousAngle{ // 値があれば
                                    var angleChange = dragAngle - previousAngle // 変わった角度の大きさ
                                    
                                    // formatter
                                    angleChange = angleFormatter180(degAngle: angleChange)
                                    angleValue += angleChange
                                    angleValue = angleSnapper(degAngle: angleFormatterSec(degAngle: angleValue),
                                                              snapAmount: secConfig.snapCount, enableSnap: isSnappy)
                                }
                                previousAngle = dragAngle
                            }
                        })
                        .onEnded { _ in
                            previousAngle = nil
                        }
                )
            // 短針
            ClockHand(angleValue: $angleValue, config: minConfig)
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged({value in
                            if isTimerRunning == false{
                                let dragAngle = angleSnapper(degAngle: returnDegAngle(config: minConfig, location: value.location),
                                                             snapAmount: minConfig.snapCount, enableSnap: true)
                                if let previousAngle = previousAngle{ // 値があれば
                                    var angleChange = dragAngle - previousAngle // 変わった角度の大きさ
                                    
                                    // formatter
                                    angleChange = angleSnapper(degAngle: angleFormatter180(degAngle: angleChange),
                                                               snapAmount: minConfig.snapCount, enableSnap: true)
                                    angleValue = angleChange * minConfig.divisor + angleValue
                                    angleValue = angleFormatterSec(degAngle: angleValue)
                                }
                                previousAngle = dragAngle
                            }
                        })
                        .onEnded { _ in
                            previousAngle = nil
                        }
                )
            Circle()
                .fill(.black)
                .frame(width: 20, height: 20)
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)
        }
    }
}
