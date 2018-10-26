//
//  Category.swift
//  BS Bingo
//
//  Created by Per Friis on 22/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension Category {
    
}





extension Category { //Class functions
    class func find(predicate:NSPredicate = NSPredicate(format:"TRUEPREDICATE"), context:NSManagedObjectContext) -> [Category] {
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return []
    }
    
    class func find(name:String, context:NSManagedObjectContext) -> Category? {
        return find(predicate: NSPredicate(format:"name == %@",name), context: context).first
    }
}
