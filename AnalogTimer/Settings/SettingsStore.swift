//
//  SettingsStore.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/21.
//

import SwiftUI

final class SettingsStore: ObservableObject{
    @AppStorage("isHapticsOn") var isHapticsOn: Bool = true
    @AppStorage("isAlarmEnabled") var isAlarmEnabled: Bool = true // Alarm？？
    
    // ここに複数の時計デザインを入れる
    
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
    
    func resetSettings() {
        isHapticsOn = true
        isAlarmEnabled = true
    }
}
