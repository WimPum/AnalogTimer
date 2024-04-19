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
    @AppStorage("DurationSec") private var DurationSec: Int = 20 // 残り時間（秒）設定用です
    @AppStorage("DurationMin") private var DurationMin: Int = 40 // 残り時間（分）
    var body: some View {
        VStack {
            ZStack(){ // タイマーの輪っか
                Circle()
                    .stroke(Color.green, style: StrokeStyle(lineWidth:10))
                    .scaledToFit()
                    .padding(10)
                Circle()
                    .trim(from: 0.0, to: timerCtrl.remainAmount)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .scaledToFit()
                    .padding(10)
                    .rotationEffect(.degrees(-90))
            }
            Text("\(String(format: "%02d", Int(timerCtrl.cleanedTime / 60))):\(String(format: "%02d", Int(timerCtrl.cleanedTime) % 60))") // 数字でタイマー表示(分:秒)
                .font(.largeTitle)
                .padding()
            
            HStack { // ピッカー
                Picker(selection: $DurationMin, label: Text("")){
                    ForEach(0..<60, id: \.self) { i in
                        Text("\(i) min").tag(i)
                    }
                }
                Picker(selection: $DurationSec, label: Text("")){
                    ForEach(0..<60, id: \.self) { i in
                        Text("\(i) sec").tag(i)
                    }
                }
            }.pickerStyle(WheelPickerStyle())
            HStack(){ // ボタンたち
                Spacer()
                Button(action: {
                    if (timerCtrl.timer == nil) {
                        timerCtrl.startTimer(interval: 0.01) // intervalは秒？
                    } else {
                        timerCtrl.stopTimer()
                    }
                }){
                    Text((timerCtrl.timer != nil) ? "Stop Timer" : "Start Timer")
                }
                Spacer()
                Button(action: {
                    timerCtrl.stopTimer()
                    timerCtrl.cleanedTime = Double(DurationMin * 60 + DurationSec)
                    timerCtrl.maxValue = timerCtrl.cleanedTime
                    timerCtrl.remainAmount = 1 // リセットしたら満タン
                }){
                    Text("Reset Timer")//.border(Color.green, width: 2)
                }
                Spacer()
            }
        }
        .onAppear(){
            timerCtrl.cleanedTime = Double(DurationMin * 60 + DurationSec)
            timerCtrl.maxValue = timerCtrl.cleanedTime
        }
    }


}

#Preview {
    ContentView()
        .environmentObject(TimerLogic())
}
