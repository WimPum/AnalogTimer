//
//  PreviewSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/28.
//

import SwiftUI

struct PreviewSlider: View{ // 実験用View
    @State private var controlValueInner: Double = 0.0
    @State private var controlValueOuter: Double = 0.0
    var body: some View{
        VStack{
            ZStack(){
                LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                Text("\(String(format: "%02d", Int(controlValueInner))):\(String(format: "%02d", Int(controlValueOuter)))")
                    .font(.system(size: CGFloat(80), weight: .light, design: .default))
                    .foregroundStyle(Color.white)
                    .padding()
                ClockTicks(radius: 170, tickCount: 60, tickWidth: 6, tickLength: 12) // 小さい方
                ClockTicks(radius: 161, tickCount: 12, tickWidth: 10, tickLength: 35) // 大きい方
                CircularSlider(controlValue: $controlValueInner, // second
                               config: Config(color: Color.green,
                                              minValue: 0, maxValue: 60, snapCount: 60,
                                              knobRadius: 20, radius: 90, tipLength: 40))
                CircularSlider(controlValue: $controlValueOuter, // minute
                               config: Config(color: Color.orange,
                                              minValue: 0, maxValue: 60, snapCount: 60,
                                              knobRadius: 15, radius: 140, tipLength: 30))
                Circle() // つかむところ
                    .fill(.black)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

#Preview {
    PreviewSlider()
}
