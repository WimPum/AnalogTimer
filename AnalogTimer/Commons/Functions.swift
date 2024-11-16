//
//  Functions.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/05/25.
//

import SwiftUI
import UIKit

//MARK: Functions

// タッチされた場所から度数法で角度を返す
// .pi/2は90度 初めに90°プラスした状態だからatan2の角度から90°引く
// 針が1番上に来る時が0°
func returnDegAngle(config: HandConfig, location: CGPoint) -> CGFloat{
    // ベクトル化
    let vector = CGVector(dx: location.x, dy: location.y)

    // 角度算出 ここはradians
    let angle = atan2((config.tailLength + config.knobLength) - vector.dy,
                      (config.tailLength + config.knobLength) - vector.dx) - .pi / 2
    return angleFormatter360(degAngle: rad2deg(radAngle: angle))
}

// 秒針用
func returnDegAngleSec(config: HandConfig, location: CGPoint) -> CGFloat{
    // ベクトル化
    let vector = CGVector(dx: location.x, dy: location.y)

    // 角度算出 ここはradians
    let angle = atan2((config.knobLength - config.tailLength) - vector.dy,
                      (config.knobLength - config.tailLength) - vector.dx) - .pi / 2
    return angleFormatter360(degAngle: rad2deg(radAngle: angle))
}

// ラジアン-度数法変換
func rad2deg (radAngle: CGFloat) -> CGFloat{
    return radAngle * 180 / .pi
}

// 回転時にスナップする
// 直したい角度と、スナップ点の数 degrees
func angleSnapper(degAngle: CGFloat, snapAmount: Int, enableSnap: Bool) -> CGFloat{
    if enableSnap == false { return degAngle } // スナップしません
    let unitAngle = CGFloat(360 / Float(snapAmount)) // やはりDegreesで OK
    let returnAngle = round(degAngle / unitAngle) * unitAngle
//    if returnAngle >= 360 { returnAngle -= 360 } // formatted
    return returnAngle
}

// 角度を0以上360未満にする 360°にはならない
func angleFormatter360(degAngle: CGFloat) -> CGFloat{
    var angle = degAngle
    if angle >= 360{
        angle -= 360
    } else if angle < 0{
        angle += 360
    }
    return angle
}

// 角度を-180°から180°にする
func angleFormatter180(degAngle: CGFloat) -> CGFloat{
    var angle = degAngle
    if angle > 180{
        angle -= 360
    } else if angle < -180{
        angle += 360
    }
    return angle
}

// 角度を0°(含む)から259,200°(含まず)にする // プロシージャルなやつにしたかった
func angleFormatterSec(degAngle: CGFloat) -> CGFloat{
    let maxAngle: CGFloat = 259_200 // 型指定
    var angle = degAngle
    if angle >= maxAngle{
        angle -= maxAngle
    } else if angle < 0{
        angle += maxAngle
    }
    return angle
}

func angleToTimeTop(angleValue: CGFloat) -> String{ // 上の方
    let hours = Int(angleValue/21_600)
    let minutes = Int((angleValue/360).truncatingRemainder(dividingBy: 60))
    let seconds = Int((angleValue/6).truncatingRemainder(dividingBy: 60))
    if hours <= 0{ // no need for hours
        return  "\(String(format: "%02d", minutes)):" +
                "\(String(format: "%02d", seconds))"
    } else {
        return  "\(String(format: "%02d", hours)):" +
                "\(String(format: "%02d", minutes))"
    }

}

func angleToTimeBottom(angleValue: CGFloat) -> String{ // 下の方 時間が表示されない時はなし
    let hours = Int(angleValue/21_600)
    let seconds = Int((angleValue/6).truncatingRemainder(dividingBy: 60))
    if hours <= 0{ // no need for hours
        return  "" // empty
    } else {
        return  "\(String(format: "%02d", seconds))"
    }

}

// 触覚を発生させます
func giveHaptics(impactType: String, ifActivate: Bool){
    if ifActivate == false{
        return
    }
    else if impactType == "soft"{
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.65)//Haptic Feedback
        //AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {} // AudioToolbox
    }
    else if impactType == "select"{
        UISelectionFeedbackGenerator().selectionChanged()//Haptic Feedback
    }
    else if impactType == "complete"{
        UINotificationFeedbackGenerator().notificationOccurred(.success)//Haptic Feedback
    }
    else if impactType == "medium"{
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 1.0)//Haptic Feedback
    }
}
