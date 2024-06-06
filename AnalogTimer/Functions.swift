//
//  Functions.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/05/25.
//

import UIKit


func returnDegAngle(config: Config, location: CGPoint) -> CGFloat{
    // ベクトル化
    let vector = CGVector(dx: location.x, dy: location.y)

    // 角度算出 ここはradians
    let angle = atan2((config.tailLength + config.knobLength) - vector.dy,
                      (config.tailLength + config.knobLength) - vector.dx) - .pi / 2 // .pi/2は90度
    
    let degAngle = rad2deg(radAngle: angle)
    return angleFormatter(degAngle: degAngle)
}

func angle2value(config: Config, degAngle: CGFloat) -> Double{
    return (config.maxValue - config.minValue) * degAngle / 360 + config.minValue
}

func angleFormatter(degAngle: CGFloat) -> CGFloat{
    var angle = degAngle
    if angle >= 360{
        angle -= 360
    } else if angle < 0{
        angle += 360
    }
    return angle
}

func angleSnapper(degAngle: CGFloat, snapAmount: Int) -> CGFloat{ // 直したい角度と、スナップ点の数 degrees
    let unitAngle = CGFloat(360 / Float(snapAmount)) // やはりDegreesで OK
    var returnAngle = round(degAngle / unitAngle) * unitAngle
    if returnAngle >= 360 { returnAngle -= 360 }
    return returnAngle
}

func rad2deg (radAngle: CGFloat) -> CGFloat{
    return radAngle * 180 / .pi
}

// 触覚を発生させます
func giveHaptics(impactType: String, ifActivate: Bool){
    if ifActivate == false{
        return
    }
    else if impactType == "soft"{
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()//Haptic Feedback
        //AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {} // AudioToolbox
    }
    else if impactType == "medium"{
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    else if impactType == "heavy"{
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    else if impactType == "rigid"{
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    else if impactType == "light"{
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
