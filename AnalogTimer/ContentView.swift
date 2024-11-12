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
        secConfig: HandConfig(divisor: 1, snapCount: 60, knobLength: 135, knobWidth: 12, tailLength: 23),
        minConfig: HandConfig(divisor: 60, snapCount: 60, knobLength: 90, knobWidth: 14, tailLength: 23),
        smallTicks: TickConfig(radius: 172, tickCount: 60, tickWidth: 6, tickLength: 12),  // 小さい方
        largeTicks: TickConfig(radius: 161, tickCount: 12, tickWidth: 12, tickLength: 34) // 目盛り
    )
    
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
            // portrait, landscapeの自動切り替え
            TabView(selection: $viewSelection){
                //MARK: 1ページ目
                GeometryReader { g in
                    DynamicStack{ // best of both worlds!! GeometryView(screensize) & DynamicStack(autorotation)
                        Spacer()
                        ClockView(angleValue: $timerCtrl.angleValue, clockConfig: clockConfig,
                                  isSnappy: configStore.isSnappEnabled, isTimerRunning: (timerCtrl.timer != nil))
                        .animation(.easeInOut, value: configStore.giveBackground())
                        .frame(width: min(g.size.width, g.size.height), height: min(g.size.width, g.size.height))
                        .scaleEffect(min(g.size.width, g.size.height)/(clockConfig.smallTicks.radius * 2 + clockConfig.smallTicks.tickLength) * 0.9)
                        Button(action: {
                            if (timerCtrl.timer == nil) {
                                timerCtrl.startTimer(interval: 0.01)
                            } else {
                                timerCtrl.stopTimer()
                            }
                        }){
                            Text((timerCtrl.timer != nil) ? "Stop Timer \(Image(systemName: "pause.fill"))" : "Start Timer \(Image(systemName: "play.fill"))") // 円にしよう
                                .foregroundStyle(.white)
                                .frame(width: 130, height: 60)
//                                .background(
//                                    RoundedRectangle(cornerRadius: CGFloat(12))
//                                        .foregroundStyle((timerCtrl.timer != nil) ? .red : .green)
//                                )
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
                    Button(action: {
                        configStore.giveRandomBgNumber()
                        withAnimation(.easeInOut){
                            timerCtrl.angleValue = 0
                        }
                        print("reset")
                    }){
                        Image(systemName: "arrow.clockwise").padding(.leading, 12.0)
                    }
                    Spacer()//左端に表示する
                    if timerCtrl.timer != nil{
                        Text("\(Image(systemName: "bell.fill")) \(timerCtrl.returnEndTime())")
                    }
                    Spacer()
                    Button(action: {self.isSettingsView.toggle()}){
                        Image(systemName: "gearshape.fill").padding(.trailing, 12.0)
                    }
                }
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
//            timerCtrl.cleanedTime = Double(DurationMin * 60 + DurationSec)
//            timerCtrl.maxValue = timerCtrl.cleanedTime
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(TimerLogic())
        .environmentObject(SettingsStore()) // environmentObjかけてるとプレビューできない
}
