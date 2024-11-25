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
    var startTime: Date = Date()
    var endTime: Date = Date()
    
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
        configureAudioSession()
        configureNotification()
    }
    
    // MARK: Timer
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
        sendNotification() // schedules notification
        
        // タイマー宣言
        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ value in
                self.angleValue = self.endTime.timeIntervalSinceNow * 6 // 6で割ったりかけたりしすぎ？
                if self.angleValue <= 0 { // タイマー終了
                    self.angleValue = 0 // clippit!!
                    if self.isAlarmEnabled == true{
                        self.isAlarmOn = true // ここで鳴ります
                    }
                    self.stopTimer()
                }
            }))
    }

    func stopTimer() { // タイマー止めます
        print("stopped timer")
        timer?.cancel()
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
        // prepare sound
        print("here!!")
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
//
//class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
//    var TimerLogic: TimerLogic
//    init(TimerLogic: TimerLogic) {
//        self.TimerLogic = TimerLogic
//    }
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.badge, .sound])
//    }
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
//            TimerLogic.isAlarmOn = false // 通知が消されたら止める。
//        }
//        completionHandler()
//    }
//}

// Stopwatch
class StopwatchLogic: ObservableObject{
    // timer
    @Published var timer: AnyCancellable? // 実際のタイマー
    @Published var angleValue: CGFloat = 0.0
    var startAngle: CGFloat = 0.0
    var startTime: Date = Date()
    
    func startTimer(interval: Double) { // limitはminuteで設定する
        // 呼び出し時の処理
        if let _timer = timer{ // もし開始時にタイマーが存在したら消す
            _timer.cancel()
        }
        
        // set start/end time
        startTime = Date()
        startAngle = angleValue
        
        // タイマー宣言
        timer = Timer.publish(every: interval, on: .main, in: .common)// intervalの間隔でthread=main
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: ({ value in
                self.angleValue = self.startAngle - self.startTime.timeIntervalSinceNow * 6 // 反対だから
            }))
    }

    func stopTimer() { // タイマー止めます
        print("stopped timer")
        timer?.cancel()
        timer = nil
    }
}
