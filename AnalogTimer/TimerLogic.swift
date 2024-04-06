//
//  TimerLogic.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/06.
//

import Foundation
import Combine

class TimerLogic: ObservableObject{
    @Published var cleanedCounter: Double = 0
    @Published var remainAmount: CGFloat = 1.0
    @Published var timer: AnyCancellable?
    
    var maxValue = 0.0
    var remainTime = 0.0 // こっちが変更されて、dispCounterは綺麗になっている方
    
    func startTimer(interval: Double) { // limitはminuteで設定する
        if let _timer = timer{
            _timer.cancel()
        } else if self.cleanedCounter <= 0{
            return
        }
        else{
            self.remainTime = self.cleanedCounter
        }
        timer = Timer.publish(every: interval, on: .main, in: .common)// interval間隔でthread=main
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ _ in
                self.remainTime -= interval
                //print("\(self.dispCounter)")
                self.cleanedCounter = floor(self.remainTime * 10) / 10
                self.remainAmount = CGFloat(self.remainTime / self.maxValue)
                if self.cleanedCounter <= 0.0 {
                    self.remainAmount = 0.0
                    self.stopTimer()
                }
            }))
    }

    func stopTimer() {
        print("stopped timer")
        timer?.cancel()
        timer = nil
    }
}
