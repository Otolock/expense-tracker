//
//  Entry+CoreDataProperties.swift
//  expenses
//
//  Created by Antonio Santos on 7/24/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date
    @NSManaged public var entryDescription: String
    @NSManaged public var id: UUID

}
