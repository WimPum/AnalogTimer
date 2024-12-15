//
//  ContentView.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/03/31.
//

import SwiftUI

struct ContentView: View {
    // EnvironmentObjects ちょっと変わるだけでも更新されちゃう
    @ObservedObject var timer: TimerLogic
    @ObservedObject var stopwatch: StopwatchLogic
    @EnvironmentObject var configStore: SettingsStore
    
    //misc
    @AppStorage("viewSelection") private var viewSelection = 2      // Starts from where you left off
    @State private var isSettingsView: Bool = false//設定画面を開く用
    
    var body: some View {
        ZStack {
            // portrait, landscapeの自動切り替え
            TabView(selection: $viewSelection){
                //MARK: - 1ページ目　タイマー
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!! GeometryView(screensize) & DynamicStack(autorotation)
                        Spacer()
                        ClockView(angleValue: $timer.angleValue, clockConfig: configStore.clockConfig,
                                  isSnappy: true, isTimerRunning: timer.isTimerActive)
                            .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                            .scaleEffect(
                                min(g.size.width, g.size.height)
                                / (configStore.clockConfig.smallTicks.radius * 2 + configStore.clockConfig.smallTicks.tickLength)
                                * 0.9
                            )
                            .onChange(of: configStore.isAlarmEnabled){ _ in // 編集された を検知
                                timer.isAlarmEnabled = configStore.isAlarmEnabled
                            }
                        Button(action: {
                            if timer.isAlarmOn == false{
                                timer.isTimerActive.toggle()
                            } else {
                                timer.isAlarmOn = false
                            }
                        }){
                            Text((timer.isTimerActive == true) // タイマー終了じゃない時
                                 ? "Stop Timer \(Image(systemName: "pause.fill"))"
                                 : (timer.isAlarmOn   // &アラームが鳴っているかどうか
                                    ? "Stop Alarm \(Image(systemName: "dot.radiowaves.left.and.right"))"
                                    : "Start Timer \(Image(systemName: "play.fill"))")  // 終了の時
                                 )
                                .foregroundStyle(.white)
                                .frame(width: 130, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: CGFloat(12))
                                        .foregroundStyle((timer.isTimerActive == true)
                                                         ? .red
                                                         : (timer.isAlarmOn   // &アラームが鳴っているかどうか
                                                            ? .orange
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
                
                //MARK: - 2ページ目　ストップウォッチ
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!!
                        Spacer()
                        ClockView(angleValue: $stopwatch.angleValue, clockConfig: configStore.clockOldConfig,
                                  isSnappy: true, isTimerRunning: true)
                            .animation((stopwatch.isStopwatchActive == true) ? .none : .spring, value: stopwatch.angleValue)
                            .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                            .scaleEffect( // ここでしかgeometryReaderの大きさは測れない?
                                min(g.size.width, g.size.height)
                                / (configStore.clockOldConfig.smallTicks.radius * 2 + configStore.clockOldConfig.smallTicks.tickLength)
                                * 0.9
                            )
                        Button(action: { stopwatch.isStopwatchActive.toggle() }){
                            Text((stopwatch.isStopwatchActive == true) // タイマー終了じゃない時
                                 ? "Stop \(Image(systemName: "pause.fill"))"
                                 : "Start \(Image(systemName: "play.fill"))") // 終了の時
                                .foregroundStyle(.white)
                                .frame(width: 130, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: CGFloat(12))
                                        .foregroundStyle((stopwatch.isStopwatchActive == true) ? .red : .green)
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
                    case 1: Text((timer.isTimerActive == true || timer.isAlarmOn == true)
                                 ? "\(Image(systemName: "bell.fill")) \(timer.returnEndTime())"
                                 : "Timer")
                    case 2: Text("Stopwatch")
                    default: Text("AnalogTimer")
                    }
                    Spacer()
                    if viewSelection == 2 {
                        Button(action: {
                            if stopwatch.isStopwatchActive == false {
                                stopwatch.angleValue = 219_060
                            }
                        }){
                            Image(systemName: "face.smiling") // fun(resets to 10:08:30)
                        }
                        Button(action: {
                            if stopwatch.isStopwatchActive == false {
                                stopwatch.angleValue = 0
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
            UIApplication.shared.isIdleTimerDisabled = true // Caffeine
        }
    }
}

//
//#Preview {
//    ContentView()
//        .environmentObject(TimerLogic())
//        .environmentObject(StopwatchLogic())
//        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
//}
