//
//  AnalogTimerApp.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/03/31.
//

import SwiftUI

@main
struct AnalogTimerApp: App {
    // persistent
    @StateObject private var timers = TimerLogic()
    @StateObject private var stopws = StopwatchLogic() // onchangeとかdidSetで関数実行をできるはず
    @StateObject private var config = SettingsStore()
    var body: some Scene {
        WindowGroup {
            ContentView(
                // Timer bindings 今度はクラスごと渡す方式に戻すつもり
                timer: timers,
                stopwatch: stopws
            )
                .environmentObject(config) // １秒に何回も更新しないから残す
        }
    }
}
