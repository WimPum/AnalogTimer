//
//  ContentView.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/03/31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerCtrl: TimerLogic // タイマー
    @FocusState private var isInputFocused: Bool //キーボードOn/Off
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(){ // タイマーの輪っか
                ClockView(minControlValue: $timerCtrl.minRemainTime, secControlValue: $timerCtrl.secRemainTime)
                    .padding(5)
                Spacer().frame(height: 50)
                Button(action: {
                    if (timerCtrl.timer == nil) {
                        timerCtrl.startTimer(interval: 0.05) // intervalは実質精度コントロール
                    } else {
                        timerCtrl.stopTimer()
                    }
                }){
                    Text((timerCtrl.timer != nil) ? "Stop Timer" : "Start Timer")
                }
                .frame(width: 130, height: 60)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: CGFloat(12))
                        .foregroundStyle(.blue)
                )
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
