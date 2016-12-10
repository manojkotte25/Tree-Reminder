//
//  Tree+CoreDataProperties.swift
//  Tree_Reminder
//
//  Created by Kondaparthy,Prem Sagar on 12/2/16.
//  Copyright © 2016 Kotte,Manoj Kumar. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tree {

    @NSManaged var date: NSDate?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var wateringinterval: NSNumber?
    @NSManaged var x: NSNumber?
    @NSManaged var y: NSNumber?

}
