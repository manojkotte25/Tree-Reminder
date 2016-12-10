import UIKit
import CoreData

class PlantView: UIImageView {
    
    let managedObjectContext : NSManagedObjectContext = (UIApplication.sharedApplication().delegate as!
        AppDelegate).managedObjectContext
    var dateFormatter:NSDateFormatter!
    var name:String!
    
    init(frame: CGRect, name:String) {
        super.init(frame: frame)
        self.name = name
        let panGR:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        let tapGR:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.addGestureRecognizer(panGR)
        self.addGestureRecognizer(tapGR)
        userInteractionEnabled = true
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT +3:00")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var startingPanLocation:CGPoint!
    
    // This function is invoked when user taps on object and details of object will be displayed
    func pan(panGR:UIPanGestureRecognizer)->Void {
        if panGR.state == .Began {
            startingPanLocation = self.frame.origin
        }
        let putativeNewFrame = CGRect(x:startingPanLocation.x + panGR.translationInView(self.superview).x, y:startingPanLocation.y + panGR.translationInView(self.superview).y, width:self.frame.size.width, height:self.frame.size.height)
        if self.superview!.bounds.contains(putativeNewFrame) {
            self.frame.origin.x = startingPanLocation.x + panGR.translationInView(self.superview).x
            self.frame.origin.y = startingPanLocation.y + panGR.translationInView(self.superview).y
        }
        if panGR.state == .Ended {
            do{
                let fetchRequest = NSFetchRequest(entityName: "Tree")
                fetchRequest.predicate = NSPredicate(format: "name contains %@",  self.name!)
                let trees = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Tree]
                trees[0].x = self.center.x
                trees[0].y = self.center.y
                try managedObjectContext.save()
            }
            catch{
                print("Something has gone wrong with the fetch request: \(error)")
            }
        }
        
    }
    
    // This function is invoked when user pans the object
    func tap(tapGR:UITapGestureRecognizer){
        do{
            let fecthRequest = NSFetchRequest(entityName: "Tree")
            let trees = try managedObjectContext.executeFetchRequest(fecthRequest) as! [Tree]
            var pointedTree:Tree!
            for tree in trees{
                if tree.name == name{
                    pointedTree = tree
                }
            }
            let alert:UIAlertView = UIAlertView(title: pointedTree.name!, message: "This \(pointedTree.type!) was planted on \(dateFormatter.stringFromDate(pointedTree.date!)) and has a watering interval of \(pointedTree.wateringinterval!) day(s)", delegate: nil, cancelButtonTitle: "ok")
            alert.show()
            print(name)
        } catch{
            print(error)
        }
    }
}
