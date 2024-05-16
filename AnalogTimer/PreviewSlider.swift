//
//  PreviewSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/28.
//

import SwiftUI

struct ClockFace: View{ // 実験用View
    // main
    @State private var controlValueMinute: Double = 0.0 // Minute:Secondの順番を守る
    @State private var controlValueSecond: Double = 0.0
    
    // clock revolution detector
    @State private var secStartAngle: Double = 0.0 // ドラッグ開始時の角度を保持する
    @State private var secAngleValue: Double = 0.0
    // 要らなそうな方
    @State private var minStartAngle: Double = 0.0 // ドラッグ開始時の角度を保持する
    @State private var minAngleValue: Double = 0.0

    @State private var passCount: Int = 0 // 通過カウント
    var body: some View{
        ZStack(){
            VStack(){
                Text("\(String(format: "%02d", Int(controlValueMinute))):\(String(format: "%02d", Int(controlValueSecond)))")
                    .font(.system(size: CGFloat(80), weight: .light, design: .default))
                    .foregroundStyle(Color.white)
                    .padding()
                Text("\(String(format: "%02d", passCount))")
                    .font(.system(size: CGFloat(40), weight: .ultraLight, design: .default))
                    .foregroundStyle(Color.white)
            }
            
            ClockTicks(radius: 170, tickCount: 60, tickWidth: 6, tickLength: 12) // 小さい方
            ClockTicks(radius: 161, tickCount: 12, tickWidth: 10, tickLength: 35) // 大きい方
            
            CircularSlider(controlValue: $controlValueMinute, // Minute 秒針とできるだけ共通で実装
                           startAngle: $minStartAngle,
                           angleValue: $minAngleValue,
                           config: Config(color: Color.green,
                                          minValue: 0, maxValue: 60, snapCount: 60,
                                          knobLength: 90, knobWidth: 11, tailLength: 23))
                .rotationEffect(Angle(degrees: 6 * (controlValueSecond / 60))) // 秒針が回ったらこっちも回転
                .onChange(of: secAngleValue) { _ in
//                    let angleSecF = angleFormatter(secAngleValue)
//                    let angleInitF = angleFormatter(secStartAngle)
                    //if secStartAngle == 0 { secStartAngle = 360 }
                    //print("AngleGap:    \(secAngleValue - secStartAngle)")
//                    print(secAngleValue)
                    let gap = secAngleValue - secStartAngle
                    
                    if gap > 0{
                        
                    }
                    
                    print("if Angle is positive: \((secAngleValue - secStartAngle >= 0) ? "YES" : "NO")")
                    print("if Angle is at Zero : \((secAngleValue == 0) ? "YES" : "NO")")
                    if secAngleValue == 0{ // 速すぎるとカウントできない
                        
                        passCount += 1
                        print("count: \(self.passCount)")
                        
                    }
//                    print("startAngle:  \(secStartAngle)")
//                    print("currentAngle:\(secAngleValue)")
//                    print("formatted    \(angleSecF - angleInitF)")
                    
                    
//                    print("HEY!!!\(controlValueSecond)")
//                    print("WHA!!!!\(clockSecState)")
//                    if controlValueSecond == 0.0 && (30..<60).contains(clockSecState){
//                        controlValueMinute += 1 // どっちから通過したか考慮しなければならない
//                    } else if controlValueSecond == 0.0 && (1..<30).contains(clockSecState){
//                        controlValueMinute -= 1
//                    }
//                    if controlValueMinute >= 60 {
//                        controlValueMinute = 0
//                    }else if controlValueMinute <= 0{
//                        controlValueMinute = 59
//                    }
//                    if controlValueSecond != 0{
//                        clockSecState = controlValueSecond
//                    }
                }
            
            CircularSlider(controlValue: $controlValueSecond, // Second
                           startAngle: $secStartAngle,
                           angleValue: $secAngleValue,
                           config: Config(color: .orange,
                                          minValue: 0, maxValue: 60, snapCount: 60,
                                          knobLength: 135, knobWidth: 9, tailLength: 23))
            
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
