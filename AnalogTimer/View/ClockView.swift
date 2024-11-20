//
//  PreviewSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/28.
//

import SwiftUI

// ClockView
// 見た目を良くします
struct ClockView: View{
    @EnvironmentObject var configStore: SettingsStore // EnvironmentObjになった設定
    
    // values
    @Binding var angleValue: CGFloat     // 角度の値 360°を超えていく 1秒は6° つまりangleValue/6=seconds
    @State private var previousAngle: CGFloat? = 0.0    // ドラッグ開始時の角度を保持する すごいやつ
    @State private var isSecDragging: Bool = false
    @State private var isMinDragging: Bool = false
    @State private var isHourDragging: Bool = false
    let clockConfig: ClockViewConfig
    
    // settings
    var isSnappy: Bool          // スナップ有無
    var isTimerRunning: Bool

    var body: some View{
        ZStack(){
//            Text(angleToTimeTop(angleValue: angleValue))
//                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .light))) // 等幅モード！！
//                .foregroundStyle(Color.white)
//                .padding()
//            Text(angleToTimeBottom(angleValue: angleValue)) // shows seconds when timer goes longer than 1h
//                .font(Font(UIFont.monospacedDigitSystemFont(ofSize: 45, weight: .light)))
//                .foregroundStyle(Color.white)
//                .padding(.top, 130)
            ClockTicks(config: clockConfig.smallTicks) // 小さい方
            ClockTicks(config: clockConfig.largeTicks) // 目盛り
            RadialNumber(config: clockConfig.radialNums)
            
            // 秒針
            SecondHand(angleValue: $angleValue, color: .orange, config: clockConfig.secConfig)
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged({value in
                            if isTimerRunning == false && isMinDragging == false && isHourDragging == false{
                                let dragAngle = angleSnapper(degAngle: returnDegAngleSec(config: clockConfig.secConfig, location: value.location),
                                                             snapAmount: clockConfig.secConfig.snapCount, enableSnap: isSnappy)
                                isSecDragging = true
                                if let previousAngle = previousAngle{ // 値があれば
                                    var angleChange = dragAngle - previousAngle // 変わった角度の大きさ
                                    
                                    // formatter
                                    angleChange = angleFormatter180(degAngle: angleChange)
                                    angleValue += angleChange
                                    angleValue = angleSnapper(degAngle: angleFormatterSec(degAngle: angleValue),
                                                              snapAmount: clockConfig.secConfig.snapCount, enableSnap: isSnappy)
                                }
                                previousAngle = dragAngle
                            }
                        })
                        .onEnded { _ in
                            isSecDragging = false
                            previousAngle = nil
                        }
                )
            
            // 分針
            ClockHand(angleValue: $angleValue, color: .white, config: clockConfig.minConfig)
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged({value in
                            if isTimerRunning == false && isSecDragging == false && isHourDragging == false{
                                let dragAngle = angleSnapper(degAngle: returnDegAngle(config: clockConfig.minConfig, location: value.location),
                                                             snapAmount: clockConfig.minConfig.snapCount, enableSnap: true)
                                isMinDragging = true
                                if let previousAngle = previousAngle{ // 値があれば
                                    var angleChange = dragAngle - previousAngle // 変わった角度の大きさ
                                    
                                    // formatter
                                    angleChange = angleSnapper(degAngle: angleFormatter180(degAngle: angleChange),
                                                               snapAmount: clockConfig.minConfig.snapCount, enableSnap: true)
                                    angleValue = angleChange * clockConfig.minConfig.divisor + angleValue
                                    angleValue = angleFormatterSec(degAngle: angleValue)
                                }
                                previousAngle = dragAngle
                            }
                        })
                        .onEnded { _ in
                            isMinDragging = false
                            previousAngle = nil
                        }
                )
            
            // 短針
            ClockHand(angleValue: $angleValue, color: .white, config: clockConfig.hourConfig)
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged({value in
                            if isTimerRunning == false && isSecDragging == false && isMinDragging == false{
                                let dragAngle = angleSnapper(degAngle: returnDegAngle(config: clockConfig.hourConfig, location: value.location),
                                                             snapAmount: clockConfig.hourConfig.snapCount, enableSnap: true)
                                isHourDragging = true
                                if let previousAngle = previousAngle{ // 値があれば
                                    var angleChange = dragAngle - previousAngle // 変わった角度の大きさ
                                    
                                    // formatter
                                    angleChange = angleSnapper(degAngle: angleFormatter180(degAngle: angleChange),
                                                               snapAmount: clockConfig.hourConfig.snapCount, enableSnap: true)
                                    angleValue = angleChange * clockConfig.hourConfig.divisor + angleValue
                                    angleValue = angleFormatterSec(degAngle: angleValue)
                                }
                                previousAngle = dragAngle
                            }
                        })
                        .onEnded { _ in
                            isHourDragging = false
                            previousAngle = nil
                        }
                )
            Circle()
                .fill(.white)
                .frame(width: 18, height: 18)
            Circle()
                .fill(.black)
                .frame(width: 7, height: 7)
//            Slider(value: $cornerRadius, in: 0...30)
        }
        .frame(height: 300)
        .onChange(of: angleValue) { _ in
            giveHaptics(impactType: "select", ifActivate: (!isTimerRunning && configStore.isHapticsOn))
        }
    }
}

struct ClockViewConfig {
    let secConfig:  HandConfig  // New
    let minConfig:  HandConfig  // 今までのsecConfigがこっち
    let hourConfig: HandConfig // 今までのminConfigがこっち
    let smallTicks: TickConfig
    let largeTicks: TickConfig
    let radialNums: RadiConfig
}

#Preview{
    @StateObject var timers = TimerLogic()
    let clockConfig = ClockViewConfig( // defines every design parameter here, geometryReader scales automatically
        secConfig:  HandConfig(knobWidth: 6,  knobLength: 210, tailLength: 40, snapCount: 60, cornerRadius: 3, divisor: 1), // Im new
        minConfig:  HandConfig(knobWidth: 12, knobLength: 130, tailLength: 20, snapCount: 60, cornerRadius: 6, divisor: 60),
        hourConfig: HandConfig(knobWidth: 14, knobLength: 90,  tailLength: 20, snapCount: 12, cornerRadius: 7, divisor: 720), // 12 snapping point
        smallTicks: TickConfig(tickWidth: 6,  tickLength: 12, radius: 178, tickCount: 60, cornerRadius: 3),  // 小さい方
        largeTicks: TickConfig(tickWidth: 12, tickLength: 34, radius: 178, tickCount: 12, cornerRadius: 6), // 目盛り
        radialNums: RadiConfig(fontSize: 30, radius: 120, count: 12)
    )
    ClockView(angleValue: $timers.angleValue, clockConfig: clockConfig,
              isSnappy: true, isTimerRunning: false)
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
}
