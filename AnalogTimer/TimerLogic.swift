//
//  TimerLogic.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/06.
//

import Foundation
import Combine

class TimerLogic: ObservableObject{
    @Published var cleanedTime: Double = 0 // これを表示に使います
    @Published var remainAmount: CGFloat = 1.0 // 0.0 ~ 1.0 残りの割合 リング用⚪︎
    @Published var timer: AnyCancellable? // 実際のタイマー
    
    var maxValue = 0.0 // 設定された時間を受け取ります
    var remainTime: Double = 0.0 // こっちが変更されて、cleanedTimeは綺麗になっている方
    // remainTimeは外からアクセスして編集します
    
    func startTimer(interval: Double) { // limitはminuteで設定する
        // 呼び出し時の処理
        if let _timer = timer{ // もし開始時にタイマーが存在したら消す
            _timer.cancel()
        } else if self.cleanedTime <= 0{ // 開始時に残り時間0だったら
            return
        }
        else{
            self.remainTime = self.cleanedTime // 多分AnalogTimerではremainTimeを直接編集することになる
        }
        
        // タイマー宣言
        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ _ in
                self.remainTime -= interval // タイマーを減らす箇所
                // print("\(self.cleanedTime)")
                self.cleanedTime = floor(self.remainTime * 10) / 10 // 秒以下を切り捨て
                self.remainAmount = CGFloat(self.remainTime / self.maxValue) // 割合の計算
                
                if self.cleanedTime <= 0.0 { // タイマー終了
                    self.remainAmount = 0.0
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
