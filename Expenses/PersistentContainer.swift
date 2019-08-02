//
//  PersistentContainer.swift
//  expenses
//
//  Created by Antonio Santos on 8/2/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import CoreData

class PersistentContainer: NSPersistentContainer {
    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
