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
    @EnvironmentObject var stopwatchCtrl: StopwatchLogic // タイマー
    @EnvironmentObject var configStore: SettingsStore
    
    //misc
    @AppStorage("viewSelection") private var viewSelection = 2      // Starts from where you left off
    @State private var isSettingsView: Bool = false//設定画面を開く用
    
    var body: some View {
        ZStack {
            // portrait, landscapeの自動切り替え
            TabView(selection: $viewSelection){
                //MARK: 1ページ目　タイマー
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!! GeometryView(screensize) & DynamicStack(autorotation)
                        Spacer()
                        ClockView(angleValue: $timerCtrl.angleValue, clockConfig: configStore.clockConfig,
                                  isSnappy: true, isTimerRunning: (timerCtrl.timer != nil))
                            .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                            .scaleEffect(
                                min(g.size.width, g.size.height)
                                / (configStore.clockConfig.smallTicks.radius * 2 + configStore.clockConfig.smallTicks.tickLength)
                                * 0.9
                            )
//                            .onChange(of: configStore.isAlarmEnabled){ _ in // 編集された を検知
//                                timerCtrl.isAlarmEnabled = configStore.isAlarmEnabled
//                            }
                        Button(action: {
                            if (timerCtrl.timer == nil) {
                                timerCtrl.isAlarmEnabled = configStore.isAlarmEnabled // 更新
                                timerCtrl.startTimer()
                            } else {
                                timerCtrl.stopTimer()
                            }
                        }){
                            Text((timerCtrl.timer != nil) // タイマー終了じゃない時
                                 ? "Stop Timer \(Image(systemName: "pause.fill"))"
                                 : (timerCtrl.isAlarmOn   // &アラームが鳴っているかどうか
                                    ? "Stop Alarm \(Image(systemName: "dot.radiowaves.left.and.right"))"
                                    : "Start Timer \(Image(systemName: "play.fill"))")  // 終了の時
                                 )
                                .foregroundStyle(.white)
                                .frame(width: 130, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: CGFloat(12))
                                        .foregroundStyle((timerCtrl.timer != nil)
                                                         ? .red
                                                         : (timerCtrl.isAlarmOn   // &アラームが鳴っているかどうか
                                                            ? .red
                                                            : .green)  // 終了の時
                                                         )
                                        .opacity(0.9)
                                    )
                        }.padding(30)
                        Spacer()
                    }
                }
//                    .background(Gradient(colors: [Color.black, Color.teal]))
                    .background(Color.black)
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Timer") }
                    .tag(1)
                
                //MARK: 2ページ目　ストップウォッチ
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!!
                        Spacer()
                        ClockView(angleValue: $stopwatchCtrl.angleValue, clockConfig: configStore.clockOldConfig,
                                  isSnappy: true, isTimerRunning: true)
                            // 頼むから.noneになったら止まってくれ
                            .animation((stopwatchCtrl.isStopwatchActive == true) ? .none : .spring, value: stopwatchCtrl.angleValue)
                            .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                            .scaleEffect(
                                min(g.size.width, g.size.height)
                                / (configStore.clockOldConfig.smallTicks.radius * 2 + configStore.clockOldConfig.smallTicks.tickLength)
                                * 0.9
                            )
                        Button(action: {
                            if (stopwatchCtrl.isStopwatchActive == false) {
                                stopwatchCtrl.startTimer()
                            } else {
                                stopwatchCtrl.stopTimer()
                            }
                        }){
                            Text((stopwatchCtrl.isStopwatchActive == true) // タイマー終了じゃない時
                                 ? "Stop \(Image(systemName: "pause.fill"))"
                                 : "Start \(Image(systemName: "play.fill"))") // 終了の時
                                .foregroundStyle(.white)
                                .frame(width: 130, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: CGFloat(12))
                                        .foregroundStyle((stopwatchCtrl.isStopwatchActive == true) ? .red : .green)
                                        .opacity(0.9)
                                    )
                        }.padding(30)
                        Spacer()
                    }
                }
                    .background(Color.black)
                    .tabItem {
                        Image(systemName: "stopwatch.fill")
                        Text("Stopwatch") }
                    .tag(2)
            }
            // MARK: Overlay - Upper buttons
            VStack(){
                Spacer().frame(height: 5)
                HStack(){
                    switch viewSelection { // Alarmがなっても終了時刻を表示できる
                    case 1: Text((timerCtrl.timer != nil || timerCtrl.isAlarmOn == true)
                                 ? "\(Image(systemName: "bell.fill")) \(timerCtrl.returnEndTime())"
                                 : "Timer")
                    case 2: Text("Stopwatch")
                    default: Text("AnalogTimer")
                    }
                    Spacer()
                    if viewSelection == 2 {
                        Button(action: {
                            if stopwatchCtrl.isStopwatchActive == false {
                                stopwatchCtrl.angleValue = 219_060
                            }
                        }){
                            Image(systemName: "face.smiling") // fun(resets to 10:08:30)
                        }
                        Button(action: {
                            if stopwatchCtrl.isStopwatchActive == false {
                                stopwatchCtrl.angleValue = 0
                            }
                        }){
                            Image(systemName: "arrow.clockwise").padding(.horizontal, 12)
                        }
                    }
                    Button(action: {self.isSettingsView.toggle()}){
                        Image(systemName: "gearshape.fill")
                    }
                }.padding(.horizontal, 12)
                .fontSemiBold(size: 24)//フォントとあるがSF Symbolsだから
                Spacer() // 全部上にあげる
            }
        }
        .preferredColorScheme(.dark)
        //設定画面
        .sheet(isPresented: self.$isSettingsView){
            SettingsView(isPresentedLocal: self.$isSettingsView)
                .sheetDetents()
        }
        .onAppear{//起動時に一回だけ実行となる このContentViewしかないから
            timerCtrl.isAlarmEnabled = configStore.isAlarmEnabled // 更新
            UIApplication.shared.isIdleTimerDisabled = true // Caffeine
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(TimerLogic())
        .environmentObject(StopwatchLogic())
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
}
