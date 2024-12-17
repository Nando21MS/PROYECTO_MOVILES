import Foundation
import CoreData

class TaskEntity: NSManagedObject, Identifiable {
    @NSManaged var title: String
    @NSManaged var reminderDate: Date?
    @NSManaged var isCompleted: Bool
    @NSManaged var userID: String?
    @NSManaged public var taskId: String?
    
    static func fetchAllTaskRequest() -> NSFetchRequest<TaskEntity> {
        NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }
}
