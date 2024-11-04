//
//  AnimGradient.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/08/04.
//

// Animatable Gradient for iOS 15 and 16

import SwiftUI

// Color but VectorArithmetic(Animatable)
struct AnimatableColor: VectorArithmetic {
    var red: Double
    var green: Double
    var blue: Double
    
    static var zero = AnimatableColor(red: 0, green: 0, blue: 0)
    
    static func - (lhs: AnimatableColor, rhs: AnimatableColor) -> AnimatableColor {
        return AnimatableColor(red: lhs.red - rhs.red, green: lhs.green - rhs.green, blue: lhs.blue - rhs.blue)
    }
    
    static func + (lhs: AnimatableColor, rhs: AnimatableColor) -> AnimatableColor {
        return AnimatableColor(red: lhs.red + rhs.red, green: lhs.green + rhs.green, blue: lhs.blue + rhs.blue)
    }
    
    mutating func scale(by rhs: Double) {
        red *= rhs
        green *= rhs
        blue *= rhs
    }
    
    var magnitudeSquared: Double {
        return red * red + green * green + blue * blue
    }
    
    static func == (lhs: AnimatableColor, rhs: AnimatableColor) -> Bool {
        return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
    }
}

// Main
struct AnimGradient: View, Animatable{
    var gradient: Gradient
    
    private var gradStartColor: AnimatableColor
    private var gradEndColor: AnimatableColor
    
    init(gradient: Gradient){
        self.gradient = gradient
        if gradient.stops == []{ // もしも色がない　なんてことがあったりしたら
            self.gradStartColor = Color.blue.animatableColor
            self.gradEndColor = Color.purple.animatableColor
        } else {
            self.gradStartColor = gradient.stops[0].color.animatableColor
            self.gradEndColor = gradient.stops[1].color.animatableColor
        }
    }
    
    // 始点アニメーション、終点アニメーション
    var animatableData: AnimatablePair<AnimatableColor, AnimatableColor>{ // はじめ　終わり？？
        get { AnimatablePair(gradStartColor, gradEndColor) }
        set {
            gradStartColor = newValue.first
            gradEndColor = newValue.second
        }
    }
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(gradStartColor), Color(gradEndColor)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension Color {
    // UIColorじゃなくてSwiftUIのColor用にCGColor
    var cgColor: CGColor? {
        return UIColor(self).cgColor // RGBを抜き出すのに使う。
    }
    
    // ただのColorをAnimatableColorに変換
    var animatableColor: AnimatableColor {
        let components = self.cgColor?.components ?? [0, 0, 0]
        return AnimatableColor(red: Double(components[0]), green: Double(components[1]), blue: Double(components[2]))
    }
    init(_ animColor: AnimatableColor) {
        self.init(red: animColor.red, green: animColor.green, blue: animColor.blue)
    }
}
