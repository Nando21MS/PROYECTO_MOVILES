//
//  Task.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import Foundation
import CoreData

class TaskEntity: NSManagedObject, Identifiable {
    @NSManaged var title: String
    @NSManaged var reminderDate: Date?
    @NSManaged var isCompleted: Bool

    static func fetchAllTaskRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
}

