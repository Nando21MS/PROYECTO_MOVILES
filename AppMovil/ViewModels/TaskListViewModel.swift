import CoreData
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    private var context: NSManagedObjectContext
    private var db = Firestore.firestore()

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAllTasks() // Inicializar con las tareas
    }

    func addTask(title: String, reminderDate: Date? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Usuario no autenticado")
            return
        }

        // Crear un identificador único para la tarea
        let taskId = UUID().uuidString

        // Crear tarea en Firestore
        let taskData: [String: Any] = [
            "taskId": taskId,
            "title": title,
            "reminderDate": reminderDate as Any,
            "isCompleted": false,
            "createdAt": FieldValue.serverTimestamp(),
            "userId": userID
        ]

        db.collection("tasks").document(userID).collection("users").document(taskId).setData(taskData) { error in
            if let error = error {
                print("Error al agregar tarea: \(error.localizedDescription)")
            } else {
                print("Tarea agregada correctamente")
                self.fetchAllTasks() // Refrescar la lista de tareas
            }
        }
    }

    func updateTask(task: TaskEntity, title: String, reminderDate: Date?) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let taskId = task.taskId else {
            print("Error: la tarea no tiene un taskId asignado")
            return
        }

        // Actualizar tarea en Firestore
        db.collection("tasks").document(userID).collection("users").document(taskId).updateData([
            "title": title,
            "reminderDate": reminderDate as Any
        ]) { error in
            if let error = error {
                print("Error al actualizar tarea: \(error.localizedDescription)")
            } else {
                print("Tarea actualizada correctamente")
                self.fetchAllTasks()
            }
        }
    }

    func toggleTaskCompletion(task: TaskEntity) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let taskId = task.taskId else {
            print("Error: la tarea no tiene un taskId asignado")
            return
        }

        // Toggle el estado de la tarea en Firestore
        let newCompletionStatus = !task.isCompleted
        db.collection("tasks").document(userID).collection("users").document(taskId).updateData([
            "isCompleted": newCompletionStatus
        ]) { error in
            if let error = error {
                print("Error al cambiar el estado de la tarea: \(error.localizedDescription)")
            } else {
                print("Estado de la tarea cambiado correctamente")
                self.fetchAllTasks()
            }
        }
    }

    func deleteTask(task: TaskEntity) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let taskId = task.taskId else {
            print("Error: la tarea no tiene un taskId asignado")
            return
        }

        // Eliminar tarea de Firestore
        db.collection("tasks").document(userID).collection("users").document(taskId).delete { error in
            if let error = error {
                print("Error al eliminar tarea: \(error.localizedDescription)")
            } else {
                print("Tarea eliminada correctamente")
                self.fetchAllTasks()
            }
        }
    }

    func fetchAllTasks() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Obtener todas las tareas de Firestore
        db.collection("tasks").document(userID).collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener tareas: \(error.localizedDescription)")
            } else {
                self.deleteAllTasksFromCoreData() // Eliminar tareas existentes en Core Data

                self.tasks = snapshot?.documents.compactMap { document in
                    let task = TaskEntity(context: self.context)
                    task.taskId = document.documentID // Asignar el ID del documento Firestore
                    task.title = document["title"] as? String ?? "Título desconocido"
                    task.reminderDate = (document["reminderDate"] as? Timestamp)?.dateValue()
                    task.isCompleted = document["isCompleted"] as? Bool ?? false
                    self.saveContext()
                    return task
                } ?? []
            }
        }
    }

    private func deleteAllTasksFromCoreData() {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchAllTaskRequest()
        do {
            let tasksInCoreData = try context.fetch(fetchRequest)
            for task in tasksInCoreData {
                context.delete(task)
            }
            saveContext()
        } catch {
            print("Error al eliminar tareas de Core Data: \(error.localizedDescription)")
        }
    }

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error al guardar contexto de Core Data: \(error.localizedDescription)")
            }
        }
    }
}
