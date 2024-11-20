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
    // 色リスト
    // ColorCombo(name: "Default",     gradColor: [Color.black, Color.gray],    handColor: [Color.orange, Color.green]),
    
    func resetSettings() {
        isHapticsOn = true
        isAlarmEnabled = true
    }
}

struct ColorCombo{
    var name: String
    var gradColor: [Color]?
    var handColor: [Color]? // sec, minの順
}
