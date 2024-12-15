//
//  Extensions.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/04/05.
//

import SwiftUI

extension View {
    //iOSバージョンで分岐 リスト背景透明化
    func scrollCBIfPossible() -> some View {
        if #available(iOS 16.0, *) {//iOS16以降ならこっちでリスト透明化
            return self.scrollContentBackground(.hidden)
        } else {
            UITableView.appearance().backgroundColor = UIColor(.clear)
            return self
        }
    }
    
    func sheetDetents() -> some View {
        if #available(iOS 16.0, *) {//iOS16以降ならこっちでリスト透明化
            return self.presentationDetents([.medium, .large])
        } else {
            return self
        }
    }
    
    //色とかフォント スタイル
    func fontLight(size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .light, design: .default))
            .foregroundStyle(.white)
    }
    func fontMedium(size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .medium, design: .default))
            .foregroundColor(.white)
    }
    func fontSemiBold(size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .semibold, design: .default))
            .foregroundColor(.white)
    }
}

// HEX(#FFFFFF)から色を指定する Stringで指定
extension Color { // from https://blog.ottijp.com/2023/12/17/swift-hex-color/
    /// create new object with hex string
    init?(hex: String, opacity: Double = 1.0) {
    // delete "#" prefix
        let hexNorm = hex.hasPrefix("#") ? String(hex.dropFirst(1)) : hex

        // scan each byte of RGB respectively
        let scanner = Scanner(string: hexNorm)
        var color: UInt64 = 0
        if scanner.scanHexInt64(&color) {
            let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(color & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        } else {
            // invalid format
            return nil
        }
    }
}
