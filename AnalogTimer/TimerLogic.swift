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

// 参考:
// https://qiita.com/scream_episode/items/8d42198698fcf7513b54
// https://github.com/yimajo/CountdownRing/
// https://digitalbunker.dev/recreating-the-ios-timer-in-swiftui/

// MARK: TimerLogic
final class TimerLogic: ObservableObject{
    // timer
    @Published var timer: AnyCancellable? // 実際のタイマー
    @Published var angleValue: CGFloat = 0.0 // 残り時間は全てこれで管理
    @AppStorage("isTimerActive") private var isTimerActive: Bool = false // タイマーは初めは存在しない
    let interval = 0.1 // theres not enough precision
    
    // Date
    private var startTime: Date = Date()
    private var endTime: Date = Date()
    @AppStorage("endTimeInterval") private var endTimeInterval: Double = 0.0 // ここから復活
    
    // sound
    @Published var isAlarmEnabled: Bool = true // config
    private var player: AVAudioPlayer!
    private let alarmSound = NSDataAsset(name: "Alarm")! // 音はWaves Flow Motionで作りました
    var isAlarmOn: Bool = false{
        didSet{
            if isAlarmOn { // 終了したら
                playAudio()
            } else if player != nil{ // falseになったら
                stopAudio()
                removeNotification()
            }
        }
    }
    
    init(){
        print("Hey its me TIMER!!")
        configureAudioSession()
        configureNotification()
        if isTimerActive == true{
            print("here!")
            endTime = Date(timeIntervalSince1970: endTimeInterval) // 復活する このendTime
            if endTime > Date.now { // タイマー終わってない
                let remainingTime = endTime.timeIntervalSinceNow // remaining time
                angleValue = remainingTime * 6
                startTimer()
            }
        }
    }
    
    // MARK: Timer
    func startTimer() { // limitはminuteで設定する
        // always stop alarm when startTimer was called
        isAlarmOn = false
        removeNotification()
        print("TIMER: Started ▶️")
        
        // 呼び出し時の処理
        if let _timer = timer{ // もし開始時にタイマーが存在したら消す
            _timer.cancel()
        } else if self.angleValue <= 0{ // 開始時に残り時間0だったら
            return
        }
        
        // set start/end time
        startTime = Date()
        endTime = startTime.addingTimeInterval(angleValue/6)
        endTimeInterval = endTime.timeIntervalSince1970 // 1970/1/1 を基準に
        sendNotification() // schedules notification
        isTimerActive = true // timer running now!
        
        // タイマー宣言
        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
            .autoconnect()
//            .prepend(Date())
            .sink { [weak self] _ in
                // MARK: Issue1
                guard let self else { return }
                self.angleValue = (self.endTime.timeIntervalSinceNow) * 6 // "interval" second late
                
                if self.angleValue < 0 { // タイマー終了
                    self.angleValue = 0 // clippit!!
                    if self.isAlarmEnabled == true{
                        self.isAlarmOn = true // ここで鳴ります
                    }
                    self.stopTimer()
                }
            }
    }

    func stopTimer() { // タイマー止めます
        print("TIMER: Stopped ⏸️")
        timer?.cancel()
        removeNotification()
//        self.angleValue = self.endTime.timeIntervalSinceNow * 6 // 多分これが重たい
        isTimerActive = false // timer cancelled
        timer = nil
    }
    
    // MARK: Audio
    func configureAudioSession(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("error: \(error)")
        }
    }
    
    //再生 silentモードだとならない あとbackground再生したい
    func playAudio(){
        player = try! AVAudioPlayer(data: alarmSound.data, fileTypeHint: "wav")
        player.numberOfLoops = -1 //ループ回数して、-1で無限ループ
        player.play()
    }
    
    func stopAudio(){
        player.stop() // pauseより滑らかじゃないけどいい
    }
    
    // MARK: Notification
    func configureNotification(){
        // 1 checking for permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permission approved!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotification(){
        let notification = UNMutableNotificationContent()
        notification.title = "AnalogTimer"
        notification.body = "Timer has reached zero at \(returnEndTime())"
        notification.sound = .default
        
        // いつ？
        let components = Calendar.current.dateComponents([.calendar, .hour, .minute, .second], from: endTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeNotification(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // cancel
        UNUserNotificationCenter.current().removeAllDeliveredNotifications() // delete
    }
    
    func formattedTime(Date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date)
    }
    
    func returnEndTime() -> String{
        return formattedTime(Date: endTime)
    }
}
