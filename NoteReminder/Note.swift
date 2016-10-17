//
//  Note.swift
//  NoteReminder
//
//  Created by Артем on 14/10/2016.
//  Copyright © 2016 Artem Salimyanov. All rights reserved.
//

import Foundation
import UserNotifications

class Note: NSObject, NSCoding {
    
    var notificationRequestIdentifier: String?
    var body: String?
    var date: Date?
    
    init(notificationRequestIdentifier: String?, body: String?, date: Date?) {
        self.notificationRequestIdentifier = notificationRequestIdentifier
        self.body = body
        self.date = date
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aCoder: NSCoder) {
        self.notificationRequestIdentifier = aCoder.decodeObject(forKey: Keys.NotificationRequestID) as! String?
        self.body = aCoder.decodeObject(forKey: Keys.Body) as! String?
        self.date = aCoder.decodeObject(forKey: Keys.Date) as! Date?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.notificationRequestIdentifier, forKey: Keys.NotificationRequestID)
        aCoder.encode(self.body, forKey: Keys.Body)
        aCoder.encode(self.date, forKey: Keys.Date)
    }
    
    struct Keys {
        static let NotificationRequestID = "notificationRequestID"
        static let Body = "body"
        static let Date = "date"
    }
}

struct RecentNotes {
    
    fileprivate static let defaults = UserDefaults.standard
    fileprivate static let key = "notes"
    
    static var notes: [Note] {
        guard let notesObject = defaults.data(forKey: key) else { return [] }
        let notes = NSKeyedUnarchiver.unarchiveObject(with: notesObject) as? [Note] ?? []
        return notes
    }

    static func add(_ note: Note) {
        var newArray = notes
        newArray.insert(note, at: 0)
        let array = NSKeyedArchiver.archivedData(withRootObject: newArray)
        defaults.set(array, forKey:key)
    }
    
    static func removeAtIndex(_ index: Int) {
        guard let notesObject = defaults.data(forKey: key) else { return }
        var notes = NSKeyedUnarchiver.unarchiveObject(with: notesObject) as? [Note] ?? []
        notes.remove(at: index)
        let array = NSKeyedArchiver.archivedData(withRootObject: notes)
        defaults.set(array, forKey:key)
    }
    
    static func insertAtIndex(_ note: Note, at index: Int) {
        var newArray = notes
        newArray.remove(at: index)
        newArray.insert(note, at: index)
        let array = NSKeyedArchiver.archivedData(withRootObject: newArray)
        defaults.set(array, forKey:key)
    }

}
