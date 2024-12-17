//
//  TaskListViewModel.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import CoreData
import UserNotifications

class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []  // Usamos TaskEntity
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAllTasks()
    }

    func addTask(title: String, reminderDate: Date? = nil) {
        let task = TaskEntity(context: context)  // Usamos TaskEntity
        task.title = title
        task.reminderDate = reminderDate
        task.isCompleted = false
        saveContext()
        fetchAllTasks()
        if let reminderDate = reminderDate {
            scheduleReminder(for: task)
        }
    }
    
    func updateTask(task: TaskEntity, title: String, reminderDate: Date?) {
        task.title = title
        task.reminderDate = reminderDate
        saveContext()
        fetchAllTasks()
    }


    func toggleTaskCompletion(task: TaskEntity) {
        task.isCompleted.toggle()  // Usamos TaskEntity
        saveContext()
        fetchAllTasks()
    }

    func deleteTask(task: TaskEntity) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [task.objectID.uriRepresentation().absoluteString]
        )
        context.delete(task)  // Usamos TaskEntity
        saveContext()
        fetchAllTasks()
    }

    func fetchAllTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchAllTaskRequest()  // Usamos TaskEntity
        do {
            tasks = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func scheduleReminder(for task: TaskEntity) {  // Usamos TaskEntity
        guard let reminderDate = task.reminderDate else { return }
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = task.title ?? "No title"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: task.objectID.uriRepresentation().absoluteString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error)")
            }
        }
    }
}
