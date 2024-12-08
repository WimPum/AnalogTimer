//
//  StopwatchLogic.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/12/08.
//

import SwiftUI
import Combine

// MARK: StopwatchLogic
class StopwatchLogic: ObservableObject{
    // timer
    @Published var angleValue: CGFloat = 0.0
    @AppStorage("startAngle") private var startAngle: Double = 0.0 // 開始時の角度(startTimeより前の情報)
    @AppStorage("isStopwatchActive") var isStopwatchActive: Bool = false // 再起動の際にStopwatchを復帰
    
    // Date
    private var startTime: Date = Date() // init
    @AppStorage("startTimeInterval") private var startTimeInterval: Double = 0.0 // startTimeを復活
    
    // CADisplayLink
    private var displayLink: CADisplayLink?
    private var previousTimestamp: CFTimeInterval = .zero
    
    init(){
        print("its me stopwatch!!")
        if isStopwatchActive == true{
            print("here, too!")
            let elapsedTime = Date(timeIntervalSince1970: startTimeInterval)
            angleValue = startAngle - elapsedTime.timeIntervalSinceNow * 6
            startTimer()
        }
    }
    
    func startTimer() { // limitはminuteで設定する
        // 呼び出し時の処理
        if let _displayLink = displayLink{ // もし開始時にタイマーが存在したら消す
            _displayLink.invalidate()
        }
        
        // set start/end time
        startTime = Date()
        startAngle = angleValue
        startTimeInterval = startTime.timeIntervalSince1970 // save
        isStopwatchActive = true // timer running now!
        
        // prepare CADisplayLink
        previousTimestamp = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
        displayLink?.add(to: .main, forMode: .common)
        
        print("STOPWATCH: Started ▶️")
        
        // タイマー宣言
//        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
//            .autoconnect()
//            .prepend(Date())
//            .sink { [weak self] _ in
//                // MARK: Issue2
//                guard let self else { return }
//                self.angleValue = self.startAngle - (self.startTime.timeIntervalSinceNow) * 6
//            }
    }
    
    // 毎フレームごとに呼ばれる
    @objc private func update(_ displayLink: CADisplayLink) {
        let delta = displayLink.targetTimestamp - previousTimestamp
//        self.angleValue = self.startAngle - (self.startTime.timeIntervalSinceNow) * 6 // sync
        let newValue = angleValue + delta * 6
        if newValue.truncatingRemainder(dividingBy: 6) == 0 {
            angleValue = startAngle - startTime.timeIntervalSinceNow * 6 // sync
        } else {
            angleValue = newValue
        }
        previousTimestamp = displayLink.targetTimestamp
    }

    func stopTimer() { // タイマー止めます
        print("STOPWATCH: Stopped ⏸️")
        displayLink?.invalidate()
        isStopwatchActive = false // stw cancelled
        displayLink = nil
    }
}
