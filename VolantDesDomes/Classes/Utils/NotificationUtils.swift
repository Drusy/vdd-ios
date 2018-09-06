//
//  NotificationUtils.swift
//  VolantDesDomes
//
//  Created by Drusy on 18/01/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift

class NotificationUtils: NSObject {
    static let shared = NotificationUtils()
    
    enum Identifier: String {
        case newArticles
    }
    
    private override init() {
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Register local notifications
    
    public func registerForLocalNotifications(completionHandler: (() -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (_, error) in
            if let error = error {
                print(error)
            }
            
            completionHandler?()
        }
    }
    
    func dismissLocalNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func scheduleLocalNotification(withTitle title: String,
                                   body: String,
                                   timeInterval: TimeInterval = 0.1,
                                   sound: Bool = true,
                                   notificationIdentifier: String? = nil,
                                   categoryIdentifier: String? = nil) {
        let identifier = notificationIdentifier ?? UUID().uuidString
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound ? UNNotificationSound.default() : nil
        content.badge = 0
        
        if let category = categoryIdentifier {
            content.categoryIdentifier = category
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationUtils: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])
    }
}
