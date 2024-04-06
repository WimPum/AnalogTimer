//
//  ContentView.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/03/31.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerCtrl: TimerLogic
    //@State private var 
    @FocusState private var isInputFocused: Bool//キーボードOn/Off
    @AppStorage("TimerDuration") private var Duration: Double = 60
    var body: some View {
        VStack {
            ZStack(){
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
            Text("\(String(format: "%02d", Int(timerCtrl.cleanedCounter / 60))):\(String(format: "%02d", Int(timerCtrl.cleanedCounter) % 60))")
                .font(.largeTitle)
                .padding()
            TextField("Enter in seconds", value: $Duration, format: .number)
                .keyboardType(.numberPad)
                .focused($isInputFocused)
                .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        print("keyboard done! pressed")
                        isInputFocused = false
                    }){
                        Text("Done").bold()
                    }
                }
            }
            HStack(){
                Spacer()
                Button(action: {
                    if (timerCtrl.timer == nil) {
                        timerCtrl.startTimer(interval: 0.01) // Limitは分で設定
                    } else {
                        timerCtrl.stopTimer()
                    }
                }){
                    Text((timerCtrl.timer != nil) ? "Stop Timer" : "Start Timer")
                }
                Spacer()
                Button(action: {
                    timerCtrl.stopTimer()
                    timerCtrl.cleanedCounter = Duration
                    timerCtrl.maxValue = Duration
                    timerCtrl.remainAmount = 1
                }){
                    Text("Reset Timer")
                }
                Spacer()
            }
        }
        .onAppear(){
            timerCtrl.cleanedCounter = Duration
            timerCtrl.maxValue = Duration
        }
    }


}

#Preview {
    ContentView()
        .environmentObject(TimerLogic())
}


