//
//  TimeReminderTableViewController.swift
//  NoteReminder
//
//  Created by Артем on 14/10/2016.
//  Copyright © 2016 Artem Salimyanov. All rights reserved.
//

import UIKit
import UserNotifications

class TimeReminderTableViewController: UITableViewController {
    
    struct Storyboard {
        static let NoteReminderCell = "NoteReminderCell"
        static let ToEditNoteSegue = "ToEditNote"
    }
    
    // MARK: Model
    var notes: [Note] {
            return RecentNotes.notes
    }
    
    let notificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func setNotes(segue: UIStoryboardSegue) {
        if let vc = segue.source as? NoteEditorViewController {
            if vc.cellIndex != nil {
                RecentNotes.insertAtIndex(vc.note, at: vc.cellIndex!)
            } else {
            RecentNotes.add(vc.note)
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoteReminderCell, for: indexPath)
        if let timeReminderCell = cell as? TimeReminderCell {
            timeReminderCell.note = notes[indexPath.row]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notes[indexPath.row].notificationRequestIdentifier ?? ""])
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [notes[indexPath.row].notificationRequestIdentifier ?? ""])
            RecentNotes.removeAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ToEditNoteSegue {
            if let vc = segue.destination.contentViewController as? NoteEditorViewController {
                if let cell = sender as? TimeReminderCell {
                vc.note = cell.note
                vc.cellIndex = tableView.indexPath(for: cell)?.row
                }
            }
        }
    }
}
