//
//  TimeReminderCell.swift
//  NoteReminder
//
//  Created by Артем on 14/10/2016.
//  Copyright © 2016 Artem Salimyanov. All rights reserved.
//

import UIKit
import UserNotifications

class TimeReminderCell: UITableViewCell {
    
    // MARK: Model
    var note: Note = Note() {
        didSet {
            updateUI()
        }
    }
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: Outlets
    @IBOutlet weak var dateReminder: UILabel!
    @IBOutlet weak var timeReminder: UILabel!
    @IBOutlet weak var bodyReminder: UILabel!
    
    private func updateUI() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        dateReminder.text = dateFormatter.string(from: (note.date)!)
        timeReminder.text = timeFormatter.string(from: (note.date)!)
        bodyReminder.text = note.body
        // Выделить заметки без расписания
        notificationCenter.getPendingNotificationRequests { (requests) in
            DispatchQueue.main.async {
                if !( requests.map() {$0.identifier}.contains((self.note.notificationRequestIdentifier) ?? "") ) {
                    self.backgroundColor = UIColor.lightGray
                } else {
                    self.backgroundColor = UIColor.white
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
