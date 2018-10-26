//
//  BSWord.swift
//  BS Bingo
//
//  Created by Per Friis on 19/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import Foundation
import CoreData

extension BSWord {
    var dto:BSWordDTO {
        get {
            return BSWordDTO(
                href:link!,
                bsWord:theWord!,
                language: language!,
                category: category?.name
            )
        }
        set {
            link = newValue.href
            theWord = newValue.bsWord
            language = newValue.language
            if let cat = newValue.category {
                category = Category.find(name: cat, context: managedObjectContext!)
            }
        }
    }
}


extension BSWord { //Class functions
    class func find(predicate:NSPredicate = NSPredicate(format:"TRUEPREDICATE"), context:NSManagedObjectContext) -> [BSWord] {
        let fetchRequest:NSFetchRequest<BSWord> = BSWord.fetchRequest()
        fetchRequest.predicate = predicate
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return []
    }
    
    class func find(link:URL, context:NSManagedObjectContext) -> BSWord? {
        return find(predicate: NSPredicate(format:"link == %@",link.absoluteString), context: context).first
    }
}
