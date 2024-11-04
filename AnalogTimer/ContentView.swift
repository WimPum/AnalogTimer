//
//  ContentView.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/03/31.
//

import SwiftUI

struct ContentView: View {
    // EnvironmentObjects
    @EnvironmentObject var timerCtrl: TimerLogic // タイマー
    @EnvironmentObject var configStore: SettingsStore
    
    @State private var isSettingsView: Bool = false//設定画面を開く用
    @State private var currentDate: Date = Date()
    var body: some View {
        ZStack {
            if #available(iOS 17, *){
                // for iOS 17 and up LinearGradient supports color animation
                LinearGradient(gradient: Gradient(colors: configStore.giveBackground()),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut, value: configStore.giveBackground())
            } else {
                // My workaround
                // Color animation works so "two color animation" == "gradient animation"
                AnimGradient(gradient: Gradient(colors: configStore.giveBackground()))
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut, value: configStore.giveBackground())
            }
            VStack(){ // タイマーの輪っか
                HStack(){
                    Spacer()//左端に表示する
                    Button(action: {self.isSettingsView.toggle()}){
                        Image(systemName: "gearshape.fill").padding(.trailing, 12.0)
                    }
                }
                .fontSemiBold(size: 24)//フォントとあるがSF Symbolsだから
                Spacer()
                ClockView(angleValue: $timerCtrl.angleValue, isSnappy: configStore.isSnappEnabled, isTimerRunning: false) // (timerCtrl.timer != nil)
                    .padding(5)
                Spacer().frame(height: 50)
                Button(action: {
                    if (timerCtrl.timer == nil) {
                        currentDate = Date.now
                        timerCtrl.startTimer(interval: 0.01) // intervalは実質精度コントロール
                    } else {
                        timerCtrl.stopTimer()
                    }
                }){
                    Text((timerCtrl.timer != nil) ? "Stop Timer" : "Start Timer")
                        .foregroundStyle(.white)
                        .frame(width: 130, height: 60)
                        .glassMaterial(cornerRadius: 12)
//                        .background(
//                            RoundedRectangle(cornerRadius: CGFloat(12))
//                                .foregroundStyle(.blue)
//                        )
                }
                
                Spacer()
            }
        }
        //設定画面
        .sheet(isPresented: self.$isSettingsView){
            SettingsView(isPresentedLocal: self.$isSettingsView)
                .sheetDetents()
        }
//        .onAppear(){
////            timerCtrl.cleanedTime = Double(DurationMin * 60 + DurationSec)
////            timerCtrl.maxValue = timerCtrl.cleanedTime
//        }
        .onAppear{//起動時に一回だけ実行となる このContentViewしかないから
            if configStore.configBgNumber > configStore.colorList.count-1{ // crash guard
                configStore.configBgNumber = 20 // hardcoded
            }
            configStore.giveRandomBgNumber()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerLogic())
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
}
