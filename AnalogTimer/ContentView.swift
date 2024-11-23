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
    @State private var viewSelection = 2    //ページを切り替える用
    @State private var isSettingsView: Bool = false//設定画面を開く用
    
    let clockConfig = ClockViewConfig( // defines every design parameter here, geometryReader scales automatically
        secConfig:  HandConfig(knobWidth: 5,  knobLength: 210, tailLength: 30, snapCount: 60, cornerRadius: 2, divisor: 1), // Im new
        minConfig:  HandConfig(knobWidth: 12, knobLength: 140, tailLength: 24, snapCount: 60, cornerRadius: 6, divisor: 60),
        hourConfig: HandConfig(knobWidth: 14, knobLength: 80,  tailLength: 24, snapCount: 12, cornerRadius: 7, divisor: 720), // 12 snapping point
        smallTicks: TickConfig(tickWidth: 2,  tickLength: 12, radius: 180, tickCount: 60, cornerRadius: 0), // 小さい方
        largeTicks: TickConfig(tickWidth: 7,  tickLength: 12, radius: 180, tickCount: 12, cornerRadius: 0), // 目盛り
        radialNums: RadiConfig(fontSize: 48, radius: 158, count: 12),
        digiTimers: DigiConfig(fontSize: 35, offset: 65)
    )
    
    let clockOldConfig = ClockViewConfig(
        secConfig:  HandConfig(knobWidth: 5,  knobLength: 210, tailLength: 30, snapCount: 60, cornerRadius: 2, divisor: 1), // Im new
        minConfig:  HandConfig(knobWidth: 12, knobLength: 140, tailLength: 24, snapCount: 60, cornerRadius: 6, divisor: 60),
        hourConfig: HandConfig(knobWidth: 14, knobLength: 80,  tailLength: 24, snapCount: 12, cornerRadius: 7, divisor: 720), // 12 snapping point
        smallTicks: TickConfig(tickWidth: 6,  tickLength: 12, radius: 180, tickCount: 60, cornerRadius: 3), // 小さい方
        largeTicks: TickConfig(tickWidth: 12, tickLength: 40, radius: 180, tickCount: 12, cornerRadius: 6), // 目盛り
        radialNums: RadiConfig(fontSize: 0, radius: 130, count: 12),
        digiTimers: DigiConfig(fontSize: 35, offset: 65)
    )
    
    var body: some View {
        ZStack {
            // portrait, landscapeの自動切り替え
            TabView(selection: $viewSelection){
                //MARK: 1ページ目　タイマー
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!! GeometryView(screensize) & DynamicStack(autorotation)
                        Spacer()
                        ClockView(angleValue: $timerCtrl.angleValue, clockConfig: clockConfig,
                                  isSnappy: true, isTimerRunning: (timerCtrl.timer != nil))
                            .onChange(of: timerCtrl.angleValue){ _ in // 編集された を検知
                                timerCtrl.isAlarmEnabled = configStore.isAlarmEnabled // 重い？？更新 BAD STUFF
                            }
                            .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                            .scaleEffect(min(g.size.width, g.size.height)/(clockConfig.smallTicks.radius * 2 + clockConfig.smallTicks.tickLength) * 0.9)
                        Button(action: {
                            if (timerCtrl.timer == nil) {
                                timerCtrl.isAlarmEnabled = configStore.isAlarmEnabled // 更新
                                timerCtrl.startTimer(interval: 0.01)
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
//                .background(Gradient(colors: [Color.black, Color.teal]))
                    .background(Color.black)
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Timer") }
                    .tag(1)
                
                //MARK: 2ページ目　ストップウォッチ
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!!
                        Spacer()
                        ClockView(angleValue: $stopwatchCtrl.angleValue, clockConfig: clockOldConfig,
                                  isSnappy: true, isTimerRunning: (stopwatchCtrl.timer != nil))
                            .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                            .scaleEffect(min(g.size.width, g.size.height)/(clockOldConfig.smallTicks.radius * 2 + clockOldConfig.smallTicks.tickLength) * 0.9)
                        Button(action: {
                            if (stopwatchCtrl.timer == nil) {
                                stopwatchCtrl.startTimer(interval: 0.01)
                            } else {
                                stopwatchCtrl.stopTimer()
                            }
                        }){
                            Text((stopwatchCtrl.timer != nil) // タイマー終了じゃない時
                                 ? "Stop \(Image(systemName: "pause.fill"))"
                                 : "Start \(Image(systemName: "play.fill"))") // 終了の時
                                .foregroundStyle(.white)
                                .frame(width: 130, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: CGFloat(12))
                                        .foregroundStyle((stopwatchCtrl.timer != nil) ? .red : .green)
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
            // Upper buttons
            VStack(){
                Spacer().frame(height: 5)
                HStack(){
                    switch viewSelection {
                    case 1: Text((timerCtrl.timer != nil) ? "\(Image(systemName: "bell.fill")) \(timerCtrl.returnEndTime())" : "Timer")
                    case 2: Text("Stopwatch")
                    default: Text("AnalogTimer")
                    }
//                    Text("Alarm: \(timerCtrl.isAlarmOn)") // 値見る用
                    Spacer()
                    Button(action: {self.isSettingsView.toggle()}){
                        Image(systemName: "gearshape.fill")//.padding(12)
                    }
                }.padding(.horizontal, 12)
                .fontSemiBold(size: 24)//フォントとあるがSF Symbolsだから
                Spacer()
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
            
            // 1 checking for permission
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("Permission approved!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(TimerLogic())
        .environmentObject(StopwatchLogic())
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
}
