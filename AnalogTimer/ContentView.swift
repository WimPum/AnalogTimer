//
//  ContentView.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/03/31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerCtrl: TimerLogic // タイマー
    @State private var isSnappy: Bool = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(){ // タイマーの輪っか
                ClockView(angleValue: $timerCtrl.angleValue, isSnappy: isSnappy, isTimerRunning: false) // (timerCtrl.timer != nil)
                    .padding(5)
                Spacer().frame(height: 50)
                Button(action: {
                    if (timerCtrl.timer == nil) {
                        timerCtrl.startTimer(interval: 0.01) // intervalは実質精度コントロール
                    } else {
                        timerCtrl.stopTimer()
                    }
                }){
                    Text((timerCtrl.timer != nil) ? "Stop Timer" : "Start Timer")
                        .foregroundStyle(.white)
                        .frame(width: 130, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: CGFloat(12))
                                .foregroundStyle(.blue)
                        )
                }
                Toggle("Snappy Snappy", isOn: $isSnappy).padding()
            }
        }
//        .onAppear(){
////            timerCtrl.cleanedTime = Double(DurationMin * 60 + DurationSec)
////            timerCtrl.maxValue = timerCtrl.cleanedTime
//        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerLogic())
}
