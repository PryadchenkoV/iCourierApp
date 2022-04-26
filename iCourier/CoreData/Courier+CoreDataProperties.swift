//
//  Courier+CoreDataProperties.swift
//  iCourier
//
//  Created by Work on 13.12.2021.
//
//

import Foundation
import CoreData


extension Courier {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Courier> {
        return NSFetchRequest<Courier>(entityName: "Courier")
    }

    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?

}

extension Courier : Identifiable {

}
