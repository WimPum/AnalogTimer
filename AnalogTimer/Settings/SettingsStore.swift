//
//  SettingsStore.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/05/21.
//

import SwiftUI

final class SettingsStore: ObservableObject{
    @AppStorage("isHapticsOn") var isHapticsOn: Bool = true
    @AppStorage("isSnappEnabled") var isSnappEnabled: Bool = true // スナップするの？？
    @AppStorage("backgroundPicker") var backgroundPicker: Int = 0    //今の背景の色設定用　設定画面ではいじれません
    @AppStorage("configBgNumber") var configBgNumber: Int = 0 // hardcodingを避けたかったが仕方なし　シャッフルがデフォ
    
    // ランダムな色セットの時は下のcolorListが使えないのでこっちで表示
    @Published var randomColorCombo: [Color] = [Color.blue, Color.purple]
    // 色リスト
    let colorList: [ColorCombo] = [ // AAAAAARRRGGGG!!!! idはstringになります 今は色かぶっててもあとで変えられるようにしたい
        ColorCombo(name: "Default",     gradColor: [Color.black, Color.gray],    handColor: [Color.orange, Color.green]),
        ColorCombo(name: "Dawn",        gradColor: [Color(hex: "5d77b9")!, Color(hex: "fadb92")!]),
        ColorCombo(name: "Twilight",    gradColor: [Color(hex: "4161b8")!, Color(hex: "e56f5e")!]),
        ColorCombo(name: "Night",       gradColor: [Color(hex: "214c80")!, Color(hex: "b6a7ea")!]),
        ColorCombo(name: "Aurora",      gradColor: [Color(hex: "7c1cbf")!, Color(hex: "5ecb92")!]),
        ColorCombo(name: "Fire",        gradColor: [Color.red, Color.yellow]),
        ColorCombo(name: "Summer",      gradColor: [Color(hex: "ccdf83")!, Color(hex: "2cde83")!]),
        ColorCombo(name: "Winter",      gradColor: [Color(hex: "dedfe3")!, Color(hex: "4a8a8b")!]),
        ColorCombo(name: "Sky",         gradColor: [Color(hex: "0645fc")!, Color(hex: "d2fafe")!]),
        ColorCombo(name: "Ocean",       gradColor: [Color(hex: "60e5ca")!, Color(hex: "374ebf")!]),
        ColorCombo(name: "Deep Ocean",  gradColor: [Color(hex: "1c6ac6")!, Color(hex: "171b5f")!]),
        ColorCombo(name: "Beach",       gradColor: [Color(hex: "2ec29e")!, Color(hex: "f2d7a7")!]),
        ColorCombo(name: "Mountain",    gradColor: [Color(hex: "f59067")!, Color(hex: "63d115")!]),
        ColorCombo(name: "Teddy bear",  gradColor: [Color(hex: "b18f61")!, Color(hex: "f0ddb3")!]),
        ColorCombo(name: "Mint",        gradColor: [Color(hex: "70efda")!, Color(hex: "0d6967")!]),
        ColorCombo(name: "Grape",       gradColor: [Color.purple, Color.indigo]),
        ColorCombo(name: "Strawberry",  gradColor: [Color(hex: "ec2172")!, Color(hex: "fbd9e5")!]),
        ColorCombo(name: "Nectar",      gradColor: [Color(hex: "f6ca46")!, Color(hex: "eb7766")!]),
        ColorCombo(name: "Green Tea",   gradColor: [Color(hex: "2f9311")!, Color(hex: "e0f2e0")!]),
        ColorCombo(name: "Champagne",   gradColor: [Color(hex: "fcefc9")!, Color(hex: "cea453")!]),
        ColorCombo(name: "Shuffle",     gradColor: []), // ダミーだから色は定義されない
        ColorCombo(name: "Random",      gradColor: [])
    ]
    
    // 呼ばれた時 configBgをもとに背景を選ぶ
    // backgroundPickerが変わります
    func giveRandomBgNumber(){
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
    
    // 上のgiveRandomBgNumberで使う randomColorCombo用
    func giveRandomBackground() -> [Color]{
        return [
            Color(hue: Double.random(in: 0...1), saturation: Double.random(in: 0...1),
                  brightness: Double.random(in: 0.5...0.9)),
            Color(hue: Double.random(in: 0...1), saturation: Double.random(in: 0...1),
                  brightness: Double.random(in: 0.7...0.95))
        ]
    }
    
    // 今の背景セットを返す
    func giveBackground() -> [Color]{
        if configBgNumber == colorList.count-1 {
           return randomColorCombo
       } else if colorList[backgroundPicker].gradColor == nil || colorList[backgroundPicker].gradColor!.isEmpty{
           return [.black, .gray] // hahaha dummies
       } else {
            //print(colorList[backgroundPicker].color!)
            return colorList[backgroundPicker].gradColor!
        }
    }
    
    // 今の針色セットを返す
    func giveHandColors() -> [Color]{
        if configBgNumber == colorList.count-1 {
           return randomColorCombo // まだ残しておこう
       } else if (colorList[backgroundPicker].handColor == nil || colorList[backgroundPicker].handColor!.isEmpty) &&
                 (colorList[backgroundPicker].gradColor == nil || colorList[backgroundPicker].gradColor!.isEmpty){ // どっちもない時
           return [.red, .blue] // hahaha dummies
       } else if colorList[backgroundPicker].handColor == nil || colorList[backgroundPicker].handColor!.isEmpty{ // 背景グラデはある時
           return colorList[backgroundPicker].gradColor!
       } else {
           //print(colorList[backgroundPicker].color!)
           return colorList[backgroundPicker].handColor!
        }
    }
    
    func resetSettings() {
        isHapticsOn = true
        isSnappEnabled = true
        configBgNumber = 0
        giveRandomBgNumber()
    }
}

struct ColorCombo{
    var name: String
    var gradColor: [Color]?
    var handColor: [Color]? // sec, minの順
}
