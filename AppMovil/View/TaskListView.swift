//
//  TaskListView.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI
import CoreData

struct TaskListView: View {
    @StateObject private var viewModel: TaskListViewModel
    @State private var newTaskTitle = ""
    @State private var reminderDate: Date? = nil
    @State private var showDatePicker = false
    @State private var showingTaskDetail = false
    @State private var selectedTask: TaskEntity? = nil  // Cambiado de Task a TaskEntity
    @State private var showCompletedTasks = false  // Estado para controlar la visibilidad de tareas completadas

    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: TaskListViewModel(context: viewContext))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        // Tareas activas (no completadas)
                        ForEach(viewModel.tasks.filter { !$0.isCompleted }) { task in
                            HStack {
                                // Columna 1: Checkbox para marcar como completada
                                Button(action: {
                                    withAnimation {
                                        viewModel.toggleTaskCompletion(task: task)
                                    }
                                }) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                        .font(.title2)
                                        .padding(8)
                                        .background(Circle().fill(Color.white).shadow(radius: 3))
                                }
                                .frame(width: 50, height: 50)
                                .buttonStyle(PlainButtonStyle())

                                // Columna 2: Datos de la tarea
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color.clear)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if !task.isCompleted {
                                                selectedTask = task
                                                withAnimation {
                                                    showingTaskDetail.toggle()
                                                }
                                            }
                                        }

                                    VStack(alignment: .leading) {
                                        Text(task.title ?? "Título desconocido")
                                            .strikethrough(task.isCompleted)
                                            .foregroundColor(task.isCompleted ? .gray : .primary)
                                            .font(.headline)

                                        if let reminderDate = task.reminderDate {
                                            Text("Reminder: \(reminderDate, formatter: dateFormatter)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }

                                // Columna 3: Contenedor de eliminar
                                Button(action: {
                                    withAnimation {
                                        viewModel.deleteTask(task: task)
                                    }
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                        .padding(10)
                                        .background(Circle().fill(Color.white).shadow(radius: 3))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 8)
                            .opacity(task.isCompleted ? 0.5 : 1.0) // Menor opacidad si está completada
                            .background(
                                task.isCompleted ? Color.green.opacity(0.1) : Color.clear
                            )
                            .cornerRadius(12)
                            .transition(.move(edge: .top)) // Animación de transición suave
                        }

                        // Tareas completadas (lista desplegable)
                        DisclosureGroup("Completed Tasks") {
                            ForEach(viewModel.tasks.filter { $0.isCompleted }) { task in
                                HStack {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.toggleTaskCompletion(task: task)
                                        }
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                            .font(.title2)
                                            .padding(8)
                                            .background(Circle().fill(Color.white).shadow(radius: 3))
                                    }
                                    .frame(width: 50, height: 50)
                                    .buttonStyle(PlainButtonStyle())

                                    VStack(alignment: .leading) {
                                        Text(task.title ?? "Título desconocido")
                                            .strikethrough(task.isCompleted)
                                            .foregroundColor(task.isCompleted ? .gray : .primary)
                                            .font(.headline)

                                        if let reminderDate = task.reminderDate {
                                            Text("Reminder: \(reminderDate, formatter: dateFormatter)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                    )

                                    Button(action: {
                                        withAnimation {
                                            viewModel.deleteTask(task: task)
                                        }
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                            .padding(10)
                                            .background(Circle().fill(Color.white).shadow(radius: 3))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding(.vertical, 8)
                                .opacity(0.5) // Tareas completadas con menor opacidad
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                                .transition(.move(edge: .top)) // Animación de transición suave
                            }
                        }
                    }
                    .listStyle(PlainListStyle())

                    Spacer()

                    // Botón para agregar nueva tarea
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
                    .zIndex(1) // Esto asegura que el botón esté encima de las otras vistas

                }

                // Vista flotante para agregar o editar tarea
                if showingTaskDetail {
                    VStack {
                        Spacer()
                        TaskDetailView(
                            task: selectedTask, // Usamos TaskEntity aquí también
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
                        .frame(height: 350)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
                        )
                        .shadow(radius: 20)
                        .padding()
                        .transition(.move(edge: .bottom)) // Animación de entrada
                        .zIndex(2) // Esto asegura que el TaskDetailView esté encima del resto de las vistas
                    }
                }
            }
            .navigationTitle("Tasks")

            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
        .navigationBarBackButtonHidden(true) // Aquí oculto el botón de "back"

    }

    private func deleteTask(at offsets: IndexSet) {
        offsets.map { viewModel.tasks[$0] }.forEach(viewModel.deleteTask)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
