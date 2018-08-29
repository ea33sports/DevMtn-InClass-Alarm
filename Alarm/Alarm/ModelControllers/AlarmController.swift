//
//  AlarmController.swift
//  Alarm
//
//  Created by Eric Andersen on 8/27/18.
//  Copyright © 2018 Eric Andersen. All rights reserved.
//

import Foundation
import UserNotifications

class AlarmController {
    
    static let shared = AlarmController()
    var alarms: [Alarm] = []
    
    init() {
        alarms = mockAlarms
        loadFromPersistentStore()
    }
    
    var mockAlarms: [Alarm] = {
        let alarm1 = Alarm(fireTimeFromMidnight: 60.00, name: "alarm1")
        let alarm2 = Alarm(fireTimeFromMidnight: 30.00, name: "alarm2")
        let alarm3 = Alarm(fireTimeFromMidnight: 05.00, name: "alarm3")
        
        return [alarm1, alarm2, alarm3]
    }()
    
    
    func addAlarm(fireTimeFromMidnight: TimeInterval, name: String) -> Alarm {
        let alarm = Alarm(fireTimeFromMidnight: fireTimeFromMidnight, name: name)
        alarms.append(alarm)
        saveToPersistentStore()
        
        return alarm
    }
    
    func update(alarm: Alarm, fireTimeFromMidnight: TimeInterval, name: String) {
        alarm.name = name
        alarm.fireTimeFromMidnight = fireTimeFromMidnight
        saveToPersistentStore()
    }
    
    func delete(alarm: Alarm) {
        guard let index = alarms.index(of: alarm) else { return }
        alarms.remove(at: index)
        saveToPersistentStore()
    }
    
    
    
    func toggleEnabled(for alarm: Alarm) {
        alarm.enabled = !alarm.enabled
        saveToPersistentStore()
    }
    
    
    
    // MARK: - Load/Save
//    private func saveToPersistentStorage() {
//        guard let filePath = type(of: self).persistentAlarmsFilePath else { return }
//        NSKeyedArchiver.archiveRootObject(self.alarms, toFile: filePath)
//    }
//
//    private func loadFromPersistentStorage() {
//        guard let filePath = type(of: self).persistentAlarmsFilePath else { return }
//        guard let alarms = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [Alarm] else { return }
//        self.alarms = alarms
//    }
    
    
    // MARK: - Persistence via JSON Encoder
    func fileURL() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = path[0]
        let fileName = "alarms.json"
        let fullURL = documentDirectory.appendingPathComponent(fileName)
        
        return fullURL
    }
    
    func saveToPersistentStore() {
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(alarms)
            try data.write(to: fileURL())
        } catch {
            print("There was an error Saving to the Persistent Store \(error) \(error.localizedDescription)")
        }
    }
    
    func loadFromPersistentStore() -> [Alarm] {
        
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: fileURL())
            let alarms = try decoder.decode([Alarm].self, from: data)
            return alarms
        } catch {
            print("There was an error Loading from the Persistent Store \(error) \(error.localizedDescription)")
        }
        return []
    }
    
    
    
    // MARK: - Helpers
    static private var persistentAlarmsFilePath: String? {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        guard let documentsDirectory = directories.first as NSString? else { return nil }
        return documentsDirectory.appendingPathComponent("Alarms.plist")
    }
}


protocol AlarmScheduler {
    
    func scheduleUserNotifications(for alarm: Alarm)
    func cancelUserNotifications(for alarm: Alarm)
}


extension AlarmScheduler {
    
    func scheduleUserNotifications(for alarm: Alarm) {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Time's up"
        notificationContent.body = "Your alarm titled \(alarm.name) is done"
        notificationContent.sound = UNNotificationSound.default()
        
        guard let fireDate = alarm.fireDate else { return }
        let triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: alarm.uuid, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to add notification request, \(error.localizedDescription)")
            }
        }
    }
    
    func cancelUserNotifications(for alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.uuid])
    }
}




























































