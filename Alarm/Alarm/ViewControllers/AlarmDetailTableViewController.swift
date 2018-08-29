//
//  AlarmDetailTableViewController.swift
//  Alarm
//
//  Created by Eric Andersen on 8/27/18.
//  Copyright © 2018 Eric Andersen. All rights reserved.
//

import UIKit

class AlarmDetailTableViewController: UITableViewController, AlarmScheduler {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var alarmTitle: UITextField!
    @IBOutlet weak var disableButton: UIButton!
    
    
    
    var alarm: Alarm? {
        didSet {
            if isViewLoaded {
                updateViews()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    
    
    private func updateViews() {
        
        guard let alarm = alarm,
              let thisMorningAtMidnight = DateHelper.thisMorningAtMidnight,
              isViewLoaded
              else {
                disableButton.isHidden = true
              return }
        
            datePicker.setDate(Date(timeInterval: alarm.fireTimeFromMidnight, since: thisMorningAtMidnight), animated: true)
            alarmTitle.text = alarm.name
            alarmTitle.textAlignment = .center
        
            disableButton.isHidden = false
            if alarm.enabled {
                disableButton.setTitle("Disable", for: UIControlState())
                disableButton.backgroundColor = .red
            } else {
                disableButton.setTitle("Enable", for: UIControlState())
                disableButton.backgroundColor = .green
            }
        
        self.title = alarm.name
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        guard let title = alarmTitle.text,
              let thisMorningAtMidnight = DateHelper.thisMorningAtMidnight
              else { return }
        let timeIntervalSinceMidnight = datePicker.date.timeIntervalSince(thisMorningAtMidnight)
        if let alarm = alarm {
            AlarmController.shared.update(alarm: alarm, fireTimeFromMidnight: timeIntervalSinceMidnight, name: title)
            cancelUserNotifications(for: alarm)
            scheduleUserNotifications(for: alarm)
        } else {
            let alarm = AlarmController.shared.addAlarm(fireTimeFromMidnight: timeIntervalSinceMidnight, name: title)
            self.alarm = alarm
            scheduleUserNotifications(for: alarm)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func enableButtonTapped(_ sender: UIButton) {
        
        guard let alarm = alarm else { return }
        AlarmController.shared.toggleEnabled(for: alarm)
        if alarm.enabled {
            scheduleUserNotifications(for: alarm)
        } else {
            cancelUserNotifications(for: alarm)
        }
        
        updateViews()
    }
}






















































