//
//  TimerLogic.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/06.
//

import Foundation
import Combine

class TimerLogic: ObservableObject{
    @Published var timer: AnyCancellable? // 実際のタイマー
    @Published var angleValue: CGFloat = 0.0
    // remainTimeは外からアクセスして編集します
    
    func startTimer(interval: Double) { // limitはminuteで設定する
        // 呼び出し時の処理
        if let _timer = timer{ // もし開始時にタイマーが存在したら消す
            _timer.cancel()
        } else if self.angleValue <= 0{ // 開始時に残り時間0だったら
            return
        }
        // タイマー宣言
        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ _ in
                self.angleValue -= interval * 6 // タイマーを減らす箇所 6°で１秒だから
                if self.angleValue <= 0 { // タイマー終了
                    self.stopTimer()
                }
            }))
    }

    func stopTimer() { // タイマー止めます
        print("stopped timer")
        timer?.cancel()
        timer = nil
    }
}
