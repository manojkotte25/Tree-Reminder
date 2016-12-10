import CoreData
import UIKit

class GardenViewController: UIViewController {
    
    @IBOutlet weak var gardenView: UIView!
    
    // To move the object through out the garden
    @IBAction func interactionBTN(sender: UIButton) {
        if gardenView.userInteractionEnabled == true{
            sender.setImage(UIImage(named: "Lock"),forState:.Normal)
            gardenView.userInteractionEnabled = false
        }else{
            sender.setImage(UIImage(named: "Unlock"),forState:.Normal)
            gardenView.userInteractionEnabled = true
        }
    }
    
    let managedObjectContext : NSManagedObjectContext = (UIApplication.sharedApplication().delegate as!
        AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "help" {
            let sendingVC : EntryViewController = segue.destinationViewController as! EntryViewController
            sendingVC.imageName = segue.identifier
        }
    }
    
    // Unwind method which is invoke when the user taps on submit button in the EntryViewController
    @IBAction func unwindToTree(segue:UIStoryboardSegue){
        let sender = segue.sourceViewController as! EntryViewController
        let plantName = sender.plantNameTF.text!
        let frame = CGRectMake(100, 100, 44, 44)
        let plantView = PlantView(frame : frame, name: plantName)
        plantView.userInteractionEnabled = true
        plantView.image = UIImage(named: sender.imageName)
        plantView.contentMode = UIViewContentMode.ScaleAspectFit
        gardenView.addSubview(plantView)
    }
    
    // Unwind method fro done button
    @IBAction func Done(segue:UIStoryboardSegue){
    }
    
    // Unwind method for cancel button
    @IBAction func cancel(segue:UIStoryboardSegue){
    }
    
    override func viewWillAppear(animated: Bool) {
        for subView in gardenView.subviews{
            subView.removeFromSuperview()
        }
        do{
            let fetchRequest = NSFetchRequest(entityName: "Tree")
            let trees = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Tree]
            for tree in trees{
                let frame = CGRectMake(100, 100, 44, 44)
                let plantView = PlantView(frame : frame, name:tree.name!)
                plantView.center = CGPoint(x:CGFloat(tree.x!), y:CGFloat(tree.y!))
                plantView.image = UIImage(named: tree.type!)
                plantView.contentMode = UIViewContentMode.ScaleAspectFit
                gardenView.addSubview(plantView)
            }
        }
        catch{
            print(error)
        }
    }
}

