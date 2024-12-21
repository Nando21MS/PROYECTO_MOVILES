import SwiftUI
import CoreData

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var newTaskTitle = ""
    @State private var reminderDate: Date? = nil
    @State private var showDatePicker = false
    @State private var showingTaskDetail = false
    @State private var selectedTask: TaskEntity? = nil
    @State private var showCompletedTasks = false
    
    @Binding var isLoggedOut: Bool // Recibir estado de cierre de sesión

    init(viewContext: NSManagedObjectContext, isLoggedOut: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: TaskListViewModel(context: viewContext))
        _isLoggedOut = isLoggedOut
    }

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                List {
                    // Tareas activas (no completadas)
                    ForEach(viewModel.tasks.filter { !$0.isCompleted }) { task in
                        taskRow(task: task)
                    }

                    // Tareas completadas (lista desplegable)
                    DisclosureGroup("Completed Tasks") {
                        ForEach(viewModel.tasks.filter { $0.isCompleted }) { task in
                            taskRow(task: task)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: .infinity)

                Spacer()

                HStack {
                    Spacer()
                    Button(action: {
                        newTaskTitle = ""
                        reminderDate = nil
                        showDatePicker = false
                        selectedTask = nil
                        withAnimation {
                            showingTaskDetail.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Circle().fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                            .shadow(radius: 10)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }

            if showingTaskDetail {
                VStack {
                    Spacer()
                    TaskDetailView(
                        task: selectedTask,
                        onSave: { title, reminderDate in
                            if let task = selectedTask {
                                viewModel.updateTask(task: task, title: title, reminderDate: reminderDate)
                            } else {
                                viewModel.addTask(title: title, reminderDate: reminderDate)
                            }
                            withAnimation {
                                showingTaskDetail = false
                            }
                        },
                        onCancel: {
                            withAnimation {
                                showingTaskDetail = false
                            }
                        }
                    )
                    .frame(height: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
                    )
                    .shadow(radius: 12)
                    .padding()
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationTitle("Tasks")
        .navigationBarItems(trailing: profileMenu) // Menú del perfil en la barra superior derecha
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func taskRow(task: TaskEntity) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                withAnimation {
                    viewModel.toggleTaskCompletion(task: task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Título desconocido")
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .font(.subheadline)

                if let reminderDate = task.reminderDate {
                    Text("Reminder: \(reminderDate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: {
                withAnimation {
                    viewModel.deleteTask(task: task)
                }
            }) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
    }

    private var profileMenu: some View {
        Menu {
            Button(action: {
                print("Mi cuenta tapped")
            }) {
                Label("Mi cuenta", systemImage: "person.fill")
            }

            Button(action: {
                print("Papelera tapped")
            }) {
                Label("Papelera", systemImage: "trash.fill")
            }

            Button(action: {
                isLoggedOut = true // Cerrar sesión
            }) {
                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            Image(systemName: "person.circle.fill")
                .font(.title)
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
