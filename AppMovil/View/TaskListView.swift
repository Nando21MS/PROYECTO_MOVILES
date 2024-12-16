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
                                    viewModel.toggleTaskCompletion(task: task)
                                }) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                        .font(.title2)
                                }
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 10)
                                .buttonStyle(PlainButtonStyle()) // Solo el checkbox es clickeable

                                // Columna 2: Datos de la tarea
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(Color.clear)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if !task.isCompleted {
                                                selectedTask = task
                                                showingTaskDetail.toggle()
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
                                }

                                // Columna 3: Contenedor de eliminar
                                HStack {
                                    Button(action: {
                                        viewModel.deleteTask(task: task)
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .foregroundColor(.red)
                                            .font(.title2)
                                    }
                                    .buttonStyle(BorderlessButtonStyle()) // Evita conflictos de gestos
                                }
                            }
                            .padding(.vertical, 8)
                            .opacity(task.isCompleted ? 0.5 : 1.0) // Menor opacidad si está completada
                        }

                        // Tareas completadas (lista desplegable)
                        DisclosureGroup("Completed Tasks") {
                            ForEach(viewModel.tasks.filter { $0.isCompleted }) { task in
                                HStack {
                                    Button(action: {
                                        viewModel.toggleTaskCompletion(task: task)
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                            .font(.title2)
                                    }
                                    .frame(width: 40, height: 40)
                                    .padding(.trailing, 10)
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

                                    HStack {
                                        Button(action: {
                                            viewModel.deleteTask(task: task)
                                        }) {
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                                .font(.title2)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding(.vertical, 8)
                                .opacity(0.5) // Tareas completadas con menor opacidad
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
                            showingTaskDetail.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
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
                                showingTaskDetail = false
                            },
                            onCancel: {
                                showingTaskDetail = false
                            }
                        )
                        .frame(height: 300)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                    }
                }
            }
            .navigationTitle("Tasks")
        }
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
