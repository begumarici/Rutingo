//
//  NotificationManager.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 5.12.2025.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    // MARK: - Singleton
    static let shared = NotificationManager()
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("notification permission error: \(error)")
                completion(false)
                return
            }
            completion(granted)
        }
    }
    
    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    completion(true)
                default:
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Notification Management
    func scheduleNotification(for routine: Routine) {
        cancelNotification(for: routine)
        
        guard routine.hasReminder, let reminderTime = routine.reminderTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "notification_title".localized
        content.body = "notification_body".localized(with: routine.name ?? "")
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = "routine-\(routine.id?.uuidString ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("error scheduling notification: \(error)")
            }}
    }
    
    func cancelNotification(for routine: Routine) {
        let identifier = "routine-\(routine.id?.uuidString ?? UUID().uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
