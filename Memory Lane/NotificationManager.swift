//
//  NotificationManager.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/22/25.
//

import Foundation
import SwiftUI
import UserNotifications
import CoreLocation

class NotificationManager: ObservableObject {
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var notificationCount = 0
    @Published var lastNotificationTime = Date.distantPast
    @Published var lastNotificationTitle = ""
    
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        checkNotificationPermission()
    }
    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                    self.checkNotificationPermission()
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }
    
    private func checkNotificationPermission() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionStatus = settings.authorizationStatus
                print("📱 Notification permission status: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
    func scheduleMemoryNotification(for memory: Memory, at location: CLLocation) {
        guard notificationPermissionStatus == .authorized else {
            print("❌ Cannot schedule notification: Permission not granted")
            return
        }
        
        // Prevent notification spam - minimum 5 minutes between notifications
        let timeSinceLastNotification = Date().timeIntervalSince(lastNotificationTime)
        if timeSinceLastNotification < 300 {
            print("⏳ Skipping notification: Too soon since last notification (\(Int(timeSinceLastNotification))s ago)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Memory Found!"
        content.body = memory.title.isEmpty ? "You've been to this place before!" : "Remember: \(memory.title)"
        content.sound = .default
        content.badge = NSNumber(value: notificationCount + 1)
        
        content.userInfo = [
            "memoryId": memory.id.uuidString,
            "memoryTitle": memory.title,
            "latitude": memory.latitude,
            "longitude": memory.longitude
        ]
        
        let request = UNNotificationRequest(
            identifier: "memory-\(memory.id.uuidString)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    self.notificationCount += 1
                    self.lastNotificationTime = Date()
                    self.lastNotificationTitle = memory.title.isEmpty ? "Untitled Memory" : memory.title
                    print("✅ Scheduled memory notification #\(self.notificationCount) for: \(self.lastNotificationTitle)")
                    print("📍 Location: \(memory.locationString)")
                }
            }
        }
    }
    
    func printNotificationStats() {
        print("\n🔔 Notification System Status:")
        print("   - Permission status: \(notificationPermissionStatus.rawValue)")
        print("   - Notifications sent: \(notificationCount)")
        print("   - Last notification: \(lastNotificationTitle.isEmpty ? "None" : lastNotificationTitle)")
        
        if lastNotificationTime != Date.distantPast {
            let timeSinceLastNotification = Date().timeIntervalSince(lastNotificationTime)
            print("   - Time since last: \(String(format: "%.1f", timeSinceLastNotification))s ago")
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("   - Alert style: \(settings.alertStyle.rawValue)")
                print("   - Badge enabled: \(settings.badgeSetting == .enabled)")
                print("   - Sound enabled: \(settings.soundSetting == .enabled)")
            }
        }
    }
}
