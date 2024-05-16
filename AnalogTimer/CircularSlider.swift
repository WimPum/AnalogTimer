//
//  CircularSlider.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/20.
//

import SwiftUI

struct CircularSlider: View {
    @Binding var controlValue: Double // 外部の値を編集
    @Binding var startAngle: Double // ドラッグ開始時の角度を保持する
    @Binding var angleValue: Double // 今の角度
    
    let config: Config
    var body: some View {
        ZStack{
            Capsule() // つかむところ
                .fill(config.color)
                .frame(width: config.knobWidth, height: config.knobLength)
                .padding(10) // paddingがあると掴みやすい
                .offset(y: -(config.knobLength / 2 + config.tailLength)) // 初期状態
            ClockTail(length: config.tailLength)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .fill(config.color)
        }
        .frame(width: (config.tailLength + config.knobLength) * 2,
               height: (config.tailLength + config.knobLength) * 2)
        .rotationEffect(Angle.degrees(angleValue))
        .gesture(DragGesture(minimumDistance: 0.0)
            .onChanged({value in
                // 初めの角度を取得
                let rawStartAngle = returnDegAngle(location: value.startLocation)
                startAngle = angleSnapper(degAngle: rawStartAngle, snapAmount: 60)
                
                // ドラッグで角度変更
                changeAngle(location: value.location,
                            ifSnap: true)
            }))
        .onAppear{ // 開いた時点で針を表示
            updateAngle()
        }
        .onChange(of: controlValue) { _ in
            updateAngle()
        }
    }

    // 角度を変えるよう
    private func changeAngle(location: CGPoint, ifSnap: Bool){ // View内関数
        let angle = returnDegAngle(location: location)
        
        if (ifSnap == true){
            let snappedAngle = angleSnapper(degAngle: angle, snapAmount: config.snapCount) // スナップ先の角度
            //let correctedAngle = snappedAngle < 0 ? snappedAngle + 2 * .pi : snappedAngle // 範囲を0~2piにする radian
            let sliderValue = round(snappedAngle / 360 * config.maxValue)// 今の角度/円
            self.controlValue = sliderValue
            self.angleValue = snappedAngle
        } else {
            let sliderValue = angle / 360 * config.maxValue// 今の角度/円
            self.controlValue = sliderValue
            self.angleValue = angle
        }
//        print("touched \(vector)")
//        print("offset\((config.knobLength / 2 + config.tailLength))")
//        print("startAngle: \(startAngle)")
//        print("currentAngle: \(angleValue)")
    }
    
    private func returnDegAngle(location: CGPoint) -> CGFloat{
        // ベクトル化
        let vector = CGVector(dx: location.x, dy: location.y) // やはり画面内の高さのズレ

        // 角度算出 ここはradians
        let angle = atan2((config.tailLength + config.knobLength) - vector.dy, // 66がなぜちょうどいいのかわかりません
                          (config.tailLength + config.knobLength) - vector.dx) - .pi / 2 // .pi/2は90度
        
        let degAngle = rad2deg(radAngle: angle)
        
        let cleanedAngle = degAngle < 0 ? degAngle + 360 : degAngle // 0~360°
        
        return cleanedAngle
//        return angleFormatter(degAngle)
    }
    
    // 値が変わったりした時角度を更新
    private func updateAngle(){ // degrees
        let angle = 360 / config.maxValue * controlValue
        let correctedAngle = angle < 0 ? angle + 360 : angle // 範囲を0~360°にする
        angleValue = correctedAngle  // 表示された時に現在の値を反映させる
    }
}

func angleSnapper(degAngle: CGFloat, snapAmount: Int) -> CGFloat{ // 直したい角度と、スナップ点の数 degrees
    let unitAngle = CGFloat(360 / Float(snapAmount)) // やはりDegreesで OK
    var returnAngle = round(degAngle / unitAngle) * unitAngle
    if returnAngle >= 360 { returnAngle -= 360 }
    //print("unitangle:\(unitAngle), return:\(returnAngle)")
    return returnAngle
}

func rad2deg (radAngle: CGFloat) -> CGFloat{
    return radAngle * 180 / .pi
}

func angleFormatter(_ degAngle: Double) -> Double{
    var angle = degAngle * -1
    if angle < 0 {
        angle += 360
    }
    if angle >= 0 && angle < 270 {
        angle += 360
    }
    return angle
}

struct ClockTicks: View {
    let radius: CGFloat
    let tickCount: Int // 目盛りの総数
    let tickWidth: CGFloat // 目盛りの太さ
    let tickLength: CGFloat // 目盛りの長さ

    var body: some View {
        ZStack(){
            ForEach(0..<tickCount, id: \.self) { index in
                let angle = Double(index) / Double(tickCount) * 2 * .pi // 目盛りの角度
                
                // 目盛りを描画
                Rectangle()
                    .fill(Color.white)
                    .frame(width: tickWidth, height: tickLength)
                    .clipShape(Capsule())
                    .offset(x: 0, y: -radius) // 時計の中心からの距離
                    .rotationEffect(.radians(angle)) // 目盛りの位置を回転
            }
        }
    }
}

struct ClockTail: Shape {
    let length: CGFloat
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addLine(to: CGPoint(x: center.x,
                                 y: center.y - length))
        return path
    }
}

struct Config { // 位置とか設定
    let color: Color
    let minValue: CGFloat
    let maxValue: CGFloat
    let snapCount: Int // snapする数
    let knobLength: CGFloat // 長さ
    let knobWidth: CGFloat // 半径 あとで2倍する
    let tailLength: CGFloat // 針の先端の長さ
}

#Preview {
    PreviewClock()
}

