//
//  Note.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import Foundation
import CoreData
 
class Note: NSManagedObject, Identifiable {
    @NSManaged var noteId: String?
    @NSManaged var title: String
    @NSManaged var details: String?
    @NSManaged var category: String?
    @NSManaged var userID: String?

    static func fetchAllNotesRequest() -> NSFetchRequest<Note> {
        NSFetchRequest<Note>(entityName: "Note")
    }
}

