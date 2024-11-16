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
    
    //misc
    @State private var viewSelection = 1    //ページを切り替える用
    @State private var isSettingsView: Bool = false//設定画面を開く用
    
    let clockConfig = ClockViewConfig( // defines every design parameter here, geometryReader scales automatically
        secConfig:  HandConfig(divisor: 1,   snapCount: 60, knobLength: 210, knobWidth: 6,  tailLength: 40), // Im new
        minConfig:  HandConfig(divisor: 60,  snapCount: 60, knobLength: 130, knobWidth: 12, tailLength: 20),
        hourConfig: HandConfig(divisor: 720, snapCount: 12, knobLength: 90,  knobWidth: 14, tailLength: 20), // 12 snapping point
        smallTicks: TickConfig(radius: 172, tickCount: 60, tickLength: 12, tickWidth: 6),  // 小さい方
        largeTicks: TickConfig(radius: 161, tickCount: 12, tickLength: 34, tickWidth: 12) // 目盛り
    )
    
    var body: some View {
        ZStack {
            if #available(iOS 17, *){
                LinearGradient(gradient: Gradient(colors: configStore.giveBackground()),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut, value: configStore.giveBackground())
            } else {
                AnimGradient(gradient: Gradient(colors: configStore.giveBackground()))
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut, value: configStore.giveBackground())
            }
            // portrait, landscapeの自動切り替え
            TabView(selection: $viewSelection){
                //MARK: 1ページ目
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!! GeometryView(screensize) & DynamicStack(autorotation)
                        Spacer()
                        ClockView(angleValue: $timerCtrl.angleValue, clockConfig: clockConfig,
                                  isSnappy: true, isTimerRunning: (timerCtrl.timer != nil))
                            .animation(.easeInOut, value: configStore.giveBackground())
                            .onChange(of: timerCtrl.angleValue){ _ in // 編集された を検知
                                timerCtrl.isAlarmEnabled = configStore.isAlarmEnabled // 重い？？更新 BAD STUFF
                                if timerCtrl.timer == nil{
                                    timerCtrl.isClockChanged = true
                                }
                            }
                            .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                            .scaleEffect(min(g.size.width, g.size.height)/(clockConfig.smallTicks.radius * 2 + clockConfig.smallTicks.tickLength) * 0.9)
                        Button(action: {
                            if (timerCtrl.timer == nil) {
                                timerCtrl.isClockChanged = false
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
//                                .background(
//                                    RoundedRectangle(cornerRadius: CGFloat(12))
//                                        .foregroundStyle((timerCtrl.timer != nil) ? .red : .green)
                                .glassMaterial(cornerRadius: 12)
                        }.padding(30)
                        Spacer()
                    }
                }
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Main") }
                    .tag(1)
                
                //MARK: 2ページ目
                Text("Hello, World!")
                    .tabItem {
                        Image(systemName: "stopwatch.fill")
                        Text("History") }
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic)) // https://stackoverflow.com/questions/68310455/
            // Upper buttons
            VStack(){
                Spacer().frame(height: 5)
                HStack(){
                    switch viewSelection {
                    case 1: Text((timerCtrl.timer != nil) ? "\(Image(systemName: "bell.fill")) \(timerCtrl.returnEndTime())" : "Timer")
                    case 2: Text("Stopwatch")
                    default: Text("AnalogTimer")
                    }
                    Button(action: {configStore.giveRandomBgNumber()}){
                        Image(systemName: "arrow.clockwise")
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
        //設定画面
        .sheet(isPresented: self.$isSettingsView){
            SettingsView(isPresentedLocal: self.$isSettingsView)
                .sheetDetents()
        }
        .onAppear{//起動時に一回だけ実行となる このContentViewしかないから
            if configStore.configBgNumber > configStore.colorList.count-1{ // crash guard
                configStore.configBgNumber = 20 // hardcoded
            }
            configStore.giveRandomBgNumber()
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
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
}
