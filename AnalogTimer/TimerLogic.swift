//
//  TimerLogic.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/06.
//

import Foundation
import Combine

class TimerLogic: ObservableObject{
    @Published var remainAmount: CGFloat = 1.0 // 0.0 ~ 1.0 残りの割合 リング用⚪︎
    @Published var timer: AnyCancellable? // 実際のタイマー
    @Published var minRemainTime: Double = 0.0
    @Published var secRemainTime: Double = 0.0
    // remainTimeは外からアクセスして編集します
    
    func startTimer(interval: Double) { // limitはminuteで設定する
        // 呼び出し時の処理
        if let _timer = timer{ // もし開始時にタイマーが存在したら消す
            _timer.cancel()
        } else if self.minRemainTime <= 0 && self.secRemainTime <= 0{ // 開始時に残り時間0だったら
            return
        }
        // タイマー宣言
        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ _ in
                self.secRemainTime -= interval // タイマーを減らす箇所
                if self.minRemainTime <= 0 && self.secRemainTime <= 0 { // タイマー終了
                    //self.remainAmount = 0.0
                    self.stopTimer()
                }
                else if self.secRemainTime < 0{
                    self.secRemainTime = 60
                    self.minRemainTime -= 1
                }
            }))
    }

    func stopTimer() { // タイマー止めます
        print("stopped timer")
        timer?.cancel()
        timer = nil
    }
}
