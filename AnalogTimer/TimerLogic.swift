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
    @Published var angleValue: CGFloat = 0.0 // 残り時間は全てこれで管理
    @AppStorage("isTimerActive") var isTimerActive: Bool = false{ // タイマーは初めは存在しない
        didSet{
            if isTimerActive == true{ // Instructed to Start NOW
                startTimer()
            } else { // stopwatchだから単純
                stopTimer()
            }
        }
    }
    
    // Date
    private var startTime: Date = Date()
    private var endTime: Date = Date()
    @AppStorage("endTimeInterval") private var endTimeInterval: Double = 0.0 // ここから復活
    
    // CADisplayLink
    private var displayLink: CADisplayLink?
    private var previousTimestamp: CFTimeInterval = .zero
    
    // sound
    var isAlarmEnabled: Bool = true // config
    @Published var isAlarmOn: Bool = false{
        didSet{
            if isAlarmOn { // 終了したら
                playAudio()
            } else if player != nil{ // falseになったら
                stopAudio()
                removeNotification()
            }
        }
    }
    private var player: AVAudioPlayer!
    private let alarmSound = NSDataAsset(name: "Alarm")! // 音はWaves Flow Motionで作りました

    
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
        // 呼び出し時の処理
        isAlarmOn = false
        removeNotification()
        if let _displayLink = displayLink{ // もし開始時にタイマーが存在したら消す
            _displayLink.invalidate()
        }
        if self.angleValue <= 0{ // 開始時に残り時間0だったら
            isTimerActive = false
            return
        }
        
        // set start/end time
        startTime = Date()
        endTime = startTime.addingTimeInterval(angleValue/6)
        endTimeInterval = endTime.timeIntervalSince1970 // 1970/1/1 を基準に
        sendNotification() // schedules notification
        
        // prepare CADisplayLink
        previousTimestamp = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
        displayLink?.preferredFrameRateRange = .init(minimum: 15, maximum: 60, preferred: 60) // 60FPS capp
        displayLink?.add(to: .main, forMode: .common)

        print("TIMER: Started ▶️")
    }
    
    // 毎フレームごとに呼ばれる
    @objc private func update(_ displayLink: CADisplayLink) {
        let delta = displayLink.targetTimestamp - previousTimestamp
        let newValue = angleValue - delta * 6
        if newValue.truncatingRemainder(dividingBy: 6) == 0 {
            angleValue = (endTime.timeIntervalSinceNow) * 6 // "interval" second late// sync
        } else {
            angleValue = newValue
        }
        if self.angleValue < 0 { // タイマー終了
            self.angleValue = 0 // clippit!!
            if self.isAlarmEnabled == true{
                self.isAlarmOn = true // ここで鳴ります
            }
            isTimerActive = false
        }
        previousTimestamp = displayLink.targetTimestamp
    }

    func stopTimer() { // タイマー止めます
        print("TIMER: Stopped ⏸️")
        displayLink?.invalidate()
        displayLink = nil
        removeNotification()
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
