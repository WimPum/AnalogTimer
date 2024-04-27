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
    @AppStorage("DurationSec") private var DurationSec: Double = 20 // 残り時間（秒）設定用です
    @AppStorage("DurationMin") private var DurationMin: Double = 40 // 残り時間（分）
    var body: some View {
        VStack {
            ZStack(){ // タイマーの輪っか
//                Circle()
//                    .stroke(Color.green, style: StrokeStyle(lineWidth:10))
//                    .scaledToFit()
//                    .padding(10)
//                Circle()
//                    .trim(from: 0.0, to: timerCtrl.remainAmount)
//                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
//                    .scaledToFit()
//                    .padding(10)
//                    .rotationEffect(.degrees(-90))
                LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ClockTicks(radius: 170, tickCount: 60, tickWidth: 6, tickLength: 12) // 小さい方
                ClockTicks(radius: 163, tickCount: 12, tickWidth: 10, tickLength: 30) // 大きい方
                CircularSlider(controlValue: $DurationMin, // minute
                               config: Config(color: Color.orange,
                                              minValue: 0, maxValue: 60, snapCount: 60,
                                              knobRadius: 10, radius: 120, tipLength: 40))
                CircularSlider(controlValue: $DurationSec, // second
                               config: Config(color: Color.green,
                                              minValue: 0, maxValue: 60, snapCount: 60,
                                              knobRadius: 10, radius: 160, tipLength: 40))
            }
            Text("\(String(format: "%02d", Int(timerCtrl.cleanedTime / 60))):\(String(format: "%02d", Int(timerCtrl.cleanedTime) % 60))") // 数字でタイマー表示(分:秒)
                .font(.largeTitle)
                .padding()
            
//            HStack { // ピッカー
//                Picker(selection: $DurationMin, label: Text("")){
//                    ForEach(0..<60, id: \.self) { i in
//                        Text("\(i) min").tag(i)
//                    }
//                }
//                Picker(selection: $DurationSec, label: Text("")){
//                    ForEach(0..<60, id: \.self) { i in
//                        Text("\(i) sec").tag(i)
//                    }
//                }
//            }.pickerStyle(WheelPickerStyle())
            HStack(){ // ボタンたち
                Spacer()
                Button(action: {
                    if (timerCtrl.timer == nil) {
                        timerCtrl.startTimer(interval: 0.05) // intervalは実質精度コントロール
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
