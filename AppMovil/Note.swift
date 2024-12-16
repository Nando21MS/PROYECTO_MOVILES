//
//  Note.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import Foundation
import CoreData

class Note: NSManagedObject, Identifiable {
    @NSManaged var title: String
    @NSManaged var details: String?
    @NSManaged var category: String?

    static func fetchAllNotesRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }
}


