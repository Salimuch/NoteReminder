//
//  NoteEditorViewController.swift
//  NoteReminder
//
//  Created by Артем on 14/10/2016.
//  Copyright © 2016 Artem Salimyanov. All rights reserved.
//

import UIKit
import UserNotifications

class NoteEditorViewController: UIViewController {
    
    // MARK: Model
    var note: Note = Note()
    
    var cellIndex: Int?
    
    func setSaveButtonActivity() {
        if (note.date != nil && note.body != nil) {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    private func generateNotificationID() -> String {
        // create notification identifier
        let currentDate = Date()
        let dateFormetter = DateFormatter()
        dateFormetter.locale = Locale(identifier: "en_US_POSIX")
        dateFormetter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss:ms"
        let requestIdentifier = dateFormetter.string(from: currentDate)
        return requestIdentifier
    }
    
    private func configNotificationID() -> String {
        if note.notificationRequestIdentifier != nil {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [note.notificationRequestIdentifier!])
            return generateNotificationID()
        } else {
            return generateNotificationID()
        }
    }
    
    func setRemindNotification() {
        guard (note.date != nil && note.body != nil) else { return }
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: note.date!)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Note Reminder"
        content.body = note.body!
        content.sound = UNNotificationSound.default()
        
        note.notificationRequestIdentifier = configNotificationID()
        
        let request = UNNotificationRequest(identifier: note.notificationRequestIdentifier!, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("We had an error \(error)")
            }
        }
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(NoteEditorViewController.keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NoteEditorViewController.keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterFromKeyboardNotofocatons() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        self.textView.isScrollEnabled = true
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.textView.contentInset = contentInsets
        self.textView.scrollIndicatorInsets = contentInsets
        
        
        var aRect : CGRect = self.textView.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.textView {
            if (!aRect.contains(activeField.frame.origin)){
                self.textView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.textView.contentInset = contentInsets
        self.textView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.textView.isScrollEnabled = false
    }
    
    // MARK: Outlets
    @IBAction func cancelNote(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var dateTimeReminder: UITextField! {
        didSet {
            let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            leftButton.setImage(UIImage(named: "clock") , for: .normal)
            leftButton.addTarget(self, action: #selector(NoteEditorViewController.setDeteTimeReminder), for: .touchUpInside)
            dateTimeReminder.leftView = leftButton
            dateTimeReminder.leftViewMode = .always
        }
    }
    
    func setDeteTimeReminder() {
        dateTimeReminder.becomeFirstResponder()
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    @IBAction func setUpDateTimeReminder(_ sender: UITextField) {
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        let datePickerView: UIDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        datePickerView.minimumDate = Date()
        inputView.addSubview(datePickerView)
        let doneButton = configDoneButton()
        inputView.addSubview(doneButton)
        sender.inputView = inputView
        datePickerView.addTarget(self, action: #selector(NoteEditorViewController.datePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        // set button click event
        doneButton.addTarget(self, action: #selector(NoteEditorViewController.doneButton(_:)), for: UIControlEvents.touchUpInside)
        // Set the date on start.
        datePickerValueChanged(datePickerView)
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    private func configDoneButton() -> UIButton {
        let doneButton = UIButton(frame: CGRect(x: (self.view.frame.size.width/2) - (100/2), y: 0, width: 100, height: 50))
        doneButton.setTitle("Done", for: UIControlState())
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.black, for: UIControlState())
        doneButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        return doneButton
    }
    
    func datePickerValueChanged(_ sender:UIDatePicker) {
        dateTimeReminder.text = setDateText(date: sender.date)
        note.date = sender.date
    }
    
    func doneButton(_ sender:UIButton)
    {
        dateTimeReminder.resignFirstResponder()
    }
    
    private func setDateText(date: Date?) -> String {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.timeStyle = DateFormatter.Style.short
            return "  " + dateFormatter.string(from: date)
        } else { return "" }
    }
    
    private func updateUI() {
        dateTimeReminder.text = setDateText(date: note.date)
        textView.text = note.body
    }
    
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        setSaveButtonActivity()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromKeyboardNotofocatons()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UnwindToRemindersTable" {
                textView.resignFirstResponder()
                setRemindNotification()
        }
    }
}

// Проваливаемся внутрь Navigation Controller
extension UIViewController {
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController!
        } else {
            return self
        }
    }
}

// MARK: Text Field Delegate

extension NoteEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setSaveButtonActivity()
        textField.resignFirstResponder()
        return true
    }
}

// MARK: TextView Delegate

extension NoteEditorViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.body = textView.text
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        note.body = textView.text
        setSaveButtonActivity()
    }
}

