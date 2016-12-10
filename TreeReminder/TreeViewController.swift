import CoreData
import UIKit
import EventKit

class TreeViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    let managedObjectContext : NSManagedObjectContext = (UIApplication.sharedApplication().delegate as!
        AppDelegate).managedObjectContext
    var eventStore: EKEventStore!
    var reminders: [EKReminder]!
    var trees:[Tree]! = []
    var dateFormatter:NSDateFormatter!
    var treeArray:[Tree] = []
    var flowerArray:[Tree] = []
    var bushArray:[Tree] = []
    var TREE_TAG = 100
    var DATE_TAG = 101
    var INTERVAL_TAG = 102
    
    @IBOutlet var gardenTBL:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Registering nib file
        gardenTBL.registerNib(UINib(nibName: "TableViewCell", bundle: nil),
                              forCellReuseIdentifier: "trees")
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT +3:00")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        treeArray = []
        flowerArray = []
        bushArray = []
        do{
            let fetchRequest = NSFetchRequest(entityName: "Tree")
            trees = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Tree]
        }
        catch{
            print(error)
        }
        for tree in trees{
            if tree.type == "tree"{
                treeArray.append(tree)
            }else if tree.type == "flower"{
                flowerArray.append(tree)
            }else{
                bushArray.append(tree)
            }
        }
        gardenTBL.reloadData()
        self.eventStore = EKEventStore()
        self.reminders = [EKReminder]()
        self.eventStore.requestAccessToEntityType(EKEntityType.Reminder) { (granted: Bool, error: NSError?) -> Void in
            if granted{
                let predicate = self.eventStore.predicateForRemindersInCalendars(nil)
                self.eventStore.fetchRemindersMatchingPredicate(predicate, completion: { (reminders: [EKReminder]?) -> Void in
                    self.reminders = reminders
                    dispatch_async(dispatch_get_main_queue()) {
                        self.gardenTBL.reloadData()
                    }
                })
            }else{
                print("The app is not permitted to access reminders, make sure to grant permission in the settings and try again")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Function to clear he data and objects in the garden
    @IBAction func deleteGardenBTN(sender: AnyObject) {
        let alert = UIAlertController(
            title: "Warning",
            message: "Are you sure to delete all garden objects ?",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (test) -> Void in
            do {
                let fetchRequestTree = NSFetchRequest(entityName: "Tree")
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestTree)
                try self.managedObjectContext.executeRequest(batchDeleteRequest)
            } catch {
                print("Error when trying to deleting trees: \(error)")
            }
            self.treeArray = []
            self.flowerArray = []
            self.bushArray = []
            do{
                let fetchRequest = NSFetchRequest(entityName: "Tree")
                self.trees = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Tree]
            } catch{
                print(error)
            }
            for tree in self.trees{
                if tree.type == "tree"{
                    self.treeArray.append(tree)
                }else if tree.type == "flower"{
                    self.flowerArray.append(tree)
                }else{
                    self.bushArray.append(tree)
                }
            }
            self.gardenTBL.reloadData()
            for reminder in self.reminders {
                do{
                    try self.eventStore.removeReminder(reminder, commit: true)
                }catch{print(error)}
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { (test) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(
            alert,
            animated: true,
            completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return treeArray.count
        }else if section == 1 {
            return flowerArray.count
        }else {
            return bushArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("trees", forIndexPath: indexPath)
        let tree:Tree!
        if indexPath.section == 0 {
            tree = treeArray[indexPath.row]
        }else if indexPath.section == 1 {
            tree = flowerArray[indexPath.row]
        }else {
            tree = bushArray[indexPath.row]
        }
        let nameLBL:UILabel = cell.contentView.viewWithTag(TREE_TAG) as! UILabel
        let dateLBL:UILabel = cell.contentView.viewWithTag(DATE_TAG) as! UILabel
        let waterIntervalLBL:UILabel = cell.contentView.viewWithTag(INTERVAL_TAG) as! UILabel
        nameLBL.text = tree.name!
        dateLBL.text = dateFormatter.stringFromDate(tree.date!)
        waterIntervalLBL.text = "\(tree.wateringinterval!) Days"
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Trees"
        }else if section == 1 {
            return "Flowers"
        }else {
            return "Bushes"
        }
    }
}

