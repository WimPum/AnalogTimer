//
//  TimerLogic.swift
//  AnalogTimer
//
//  Created by 虎澤謙 on 2024/04/06.
//

import SwiftUI
import Combine
import AVFoundation
import UserNotifications

class TimerLogic: ObservableObject{
    // timer
    @Published var timer: AnyCancellable? // 実際のタイマー
    @Published var angleValue: CGFloat = 0.0
    @Published var isClockChanged: Bool = false // タイマー画面が変更された(回されたかどうか)
    var startTime: Date = Date()
    var endTime: Date = Date()
    
    // sound
    var isAlarmEnabled: Bool = true // config
    private var player: AVAudioPlayer!
    private let alarmSound = NSDataAsset(name: "Alarm")!
    var isAlarmOn: Bool = false{
        didSet{
            guard let player else { return }
            if isAlarmOn == false{ // falseになったら
                player.stop() // pauseより滑らかじゃないけどいい
            }
        }
    }
    
    func startTimer(interval: Double) { // limitはminuteで設定する
        // always stop alarm when startTimer was called
        isAlarmOn = false
        
        // 呼び出し時の処理
        if let _timer = timer{ // もし開始時にタイマーが存在したら消す
            _timer.cancel()
        } else if self.angleValue <= 0{ // 開始時に残り時間0だったら
            return
        }
        
        // set start/end time
        startTime = Date()
        endTime = startTime.addingTimeInterval(angleValue/6)
        sendNotification()
        
        // prepare sound
        player = try! AVAudioPlayer(data: alarmSound.data, fileTypeHint: "wav")
        player.numberOfLoops = -1 //ループ回数して、-1で無限ループ
        
        // タイマー宣言
        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ value in
                self.angleValue = self.endTime.timeIntervalSinceNow * 6 // 6で割ったりかけたりしすぎ？
                if self.angleValue <= 0 { // タイマー終了
                    self.angleValue = 0 // clippit!!
                    if self.isAlarmEnabled == true{
                        self.isAlarmOn = true
                    }
                    self.stopTimer()
                }
            }))
    }

    func stopTimer() { // タイマー止めます
        print("stopped timer")
        timer?.cancel()
        timer = nil
        if isAlarmOn == true{
            player.play()  //再生 silentモードだとならない あとbackground再生したい
        }
    }
    
    func formattedTime(Date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date)
    }
    
    func returnEndTime() -> String{
        return formattedTime(Date: endTime)
    }
    
    func sendNotification(){
        let notification = UNMutableNotificationContent()
        notification.title = "AnalogTimer"
        notification.body = "Timer has reached zero at \(returnEndTime())"
        notification.sound = .default // 是非とも変えたいところです
        
        // いつ？
        let components = Calendar.current.dateComponents([.calendar, .hour, .minute, .second], from: endTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
