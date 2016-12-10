import UIKit
import CoreData
import EventKit

// creation of a new tree
class EntryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var eventStore: EKEventStore!
    var allFieldsPresent:Bool!
    var dayArray:[Int] = []
    // Helps in formatting date
    var dateFormatter:NSDateFormatter!
    
    
    @IBOutlet weak var plantIMG: UIImageView!
    @IBOutlet weak var plantNameTF: UITextField!
    @IBOutlet weak var intervalPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as!
        AppDelegate).managedObjectContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.plantNameTF.delegate = self
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT +3:00")
        for number in 1...30 { dayArray.append(number)}
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.eventStore = EKEventStore()
        self.eventStore.requestAccessToEntityType(EKEntityType.Reminder) { (granted: Bool, error: NSError?) -> Void in
            if granted{
                let predicate = self.eventStore.predicateForRemindersInCalendars(nil)
                self.eventStore.fetchRemindersMatchingPredicate(predicate, completion: { (reminders: [EKReminder]?) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                    }
                })
            }else{
                print("The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
            }}
        plantIMG.image = UIImage(named: imageName)
        
    }
    
    var imageName:String!
    
    // When user taps on this button, the information about object will be stored in database
    @IBAction func submitButton(sender: UIButton) {
        
        allFieldsPresent = true // assume all fields are present
        if plantNameTF?.text?.characters.count > 0  {
            let tree = NSEntityDescription.insertNewObjectForEntityForName("Tree", inManagedObjectContext: managedObjectContext) as! Tree
            tree.name = plantNameTF?.text
            tree.date = datePicker.date
            tree.wateringinterval = dayArray[intervalPicker.selectedRowInComponent(0)]
            tree.type = imageName
            tree.x = 100
            tree.y = 100
            do{
                try managedObjectContext.save()
                performSegueWithIdentifier("unwindToTree", sender: nil)
                let reminder = EKReminder(eventStore: self.eventStore)
                reminder.title = plantNameTF.text!
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let dueDateComponents = appDelegate.dateComponentFromNSDate(self.datePicker.date)
                reminder.dueDateComponents = dueDateComponents
                reminder.addRecurrenceRule(EKRecurrenceRule(recurrenceWithFrequency: .Daily, interval:  dayArray[intervalPicker.selectedRowInComponent(0)], end: nil))
                reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
                let alarm:EKAlarm = EKAlarm(relativeOffset: -60)
                reminder.addAlarm(alarm)
                do {
                    try self.eventStore.saveReminder(reminder, commit: true)
                }catch{
                    print("Error creating and saving new reminder : \(error)")
                }
                
            } catch{
                
            }
        }else{
            displayMessage("Enter all fields")
            allFieldsPresent = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String,sender: AnyObject?) -> Bool {
        return identifier == "unwindToTree" && allFieldsPresent || identifier == "cancel"
    }
    
    // Function to display alert message
    func displayMessage(message:String) {
        let alert = UIAlertController(title: "", message: message,
                                      preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title:"OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert,animated:true, completion:nil)
    }
    
    @IBAction func backToEntry(segue:UIStoryboardSegue) {
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dayArray.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: "\(dayArray[row])")
    }
    
    
}
