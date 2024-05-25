//
//  AnalogTimerApp.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/03/31.
//

import SwiftUI

@main
struct AnalogTimerApp: App {
    @StateObject var timers = TimerLogic()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timers)
        }
    }
}
