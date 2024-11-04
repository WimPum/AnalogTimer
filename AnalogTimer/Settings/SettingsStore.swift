//
//  SettingsStore.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/21.
//

import SwiftUI

final class SettingsStore: ObservableObject{
    @AppStorage("isHapticsOn") var isHapticsOn: Bool = true
    @AppStorage("isSnappEnabled") var isSnappEnabled: Bool = false // スナップするの？？
    @AppStorage("backgroundPicker") var backgroundPicker: Int = 0    //今の背景の色設定用　設定画面ではいじれません
    @AppStorage("configBgNumber") var configBgNumber: Int = 0 // hardcodingを避けたかったが仕方なし　シャッフルがデフォ
    @AppStorage("isFirstRunning") var isFirstRunning: Bool = true // 初回起動ですかt/f
    
    @Published var randomColorCombo: [Color] = [Color.blue, Color.purple]
    // 色リスト
    let colorList: [ColorCombo] = [ // AAAAAARRRGGGG!!!! idはstringになります
        ColorCombo(name: "Default",
                   color: [Color.black, Color.gray]),
        ColorCombo(name: "Dawn",
                   color: [Color(hex: "5d77b9")!, Color(hex: "fadb92")!]),
        ColorCombo(name: "Twilight",
                   color: [Color(hex: "4161b8")!, Color(hex: "e56f5e")!]),
        ColorCombo(name: "Night",
                   color: [Color(hex: "214c80")!, Color(hex: "b6a7ea")!]),
        ColorCombo(name: "Aurora",
                   color: [Color(hex: "7c1cbf")!, Color(hex: "5ecb92")!]),
        ColorCombo(name: "Fire",
                   color: [Color.red, Color.yellow]),
        ColorCombo(name: "Summer",
                   color: [Color(hex: "ccdf83")!, Color(hex: "2cde83")!]),
        ColorCombo(name: "Winter",
                   color: [Color(hex: "dedfe3")!, Color(hex: "4a8a8b")!]),
        ColorCombo(name: "Sky",
                   color: [Color(hex: "0645fc")!, Color(hex: "d2fafe")!]),
        ColorCombo(name: "Ocean",
                   color: [Color(hex: "60e5ca")!, Color(hex: "374ebf")!]),
        ColorCombo(name: "Deep Ocean",
                   color: [Color(hex: "1c6ac6")!, Color(hex: "171b5f")!]),
        ColorCombo(name: "Beach",
                   color: [Color(hex: "2ec29e")!, Color(hex: "f2d7a7")!]),
        ColorCombo(name: "Mountain",
                   color: [Color(hex: "f59067")!, Color(hex: "63d115")!]),
        ColorCombo(name: "Teddy bear",
                   color: [Color(hex: "b18f61")!, Color(hex: "f0ddb3")!]),
        ColorCombo(name: "Mint",
                   color: [Color(hex: "70efda")!, Color(hex: "0d6967")!]),
        ColorCombo(name: "Grape",
                   color: [Color.purple, Color.indigo]),
        ColorCombo(name: "Strawberry",
                   color: [Color(hex: "ec2172")!, Color(hex: "fbd9e5")!]),
        ColorCombo(name: "Nectar",
                   color: [Color(hex: "f6ca46")!, Color(hex: "eb7766")!]),
        ColorCombo(name: "Green Tea",
                   color: [Color(hex: "2f9311")!, Color(hex: "e0f2e0")!]),
        ColorCombo(name: "Champagne",
                   color: [Color(hex: "fcefc9")!, Color(hex: "cea453")!]),
        ColorCombo(name: "Shuffle", color: []),
        ColorCombo(name: "Random", color: [])
    ]
    
    func giveRandomBgNumber(){ // 呼ばれた時 configBgをもとに背景を選ぶ
        if 0...colorList.count-3 ~= configBgNumber{ // 色を選んだ時
            backgroundPicker = configBgNumber
        }else if configBgNumber == colorList.count-2{  // シャッフル
            var randomBgNumber: Int
            repeat{
                randomBgNumber = Int.random(in: 0...colorList.count-3)//0...3は自分で色と対応させる
            }while backgroundPicker == randomBgNumber // 同じ背景だった時にやり直し
            backgroundPicker = randomBgNumber
        }else{ // ランダム
            randomColorCombo = giveRandomBackground()
            backgroundPicker = configBgNumber
        }
    }
    
    func giveRandomBackground() -> [Color]{
        return [
            Color(hue: Double.random(in: 0...1), saturation: Double.random(in: 0...1),
                  brightness: Double.random(in: 0.5...0.9)),
            Color(hue: Double.random(in: 0...1), saturation: Double.random(in: 0...1),
                  brightness: Double.random(in: 0.7...0.95))
        ]
    }
    
    func giveBackground() -> [Color]{ // 今の背景セットを返す
        if configBgNumber != colorList.count-1{
            //print(colorList[backgroundPicker].color!)
            return colorList[backgroundPicker].color!
        } else {
            return randomColorCombo
        }
    }
    
    func resetSettings() {
        isHapticsOn = true
        isSnappEnabled = false
        configBgNumber = 0
        giveRandomBgNumber()
        //isFirstRunning = true //permanent
    }
}

struct ColorCombo{
    var name: String
    var color: [Color]?
}
