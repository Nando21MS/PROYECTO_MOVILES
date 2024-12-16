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

    init(viewContext: NSManagedObjectContext) {
           _viewModel = StateObject(wrappedValue: TaskListViewModel(context: viewContext))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach(viewModel.tasks) { task in
                            HStack {
                                Button(action: {
                                    viewModel.toggleTaskCompletion(task: task)
                                }) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                        .font(.title2)
                                }

                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .strikethrough(task.isCompleted)
                                        .foregroundColor(task.isCompleted ? .gray : .primary)
                                        .font(.headline)

                                    if let reminderDate = task.reminderDate {
                                        Text("Reminder: \(reminderDate, formatter: dateFormatter)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTask = task  // Usamos TaskEntity aquí
                                showingTaskDetail.toggle()
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: deleteTask)
                    }
                    .listStyle(PlainListStyle())

                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            newTaskTitle = ""
                            reminderDate = nil
                            showDatePicker = false
                            showingTaskDetail.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
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
                            task: selectedTask,  // Usamos TaskEntity aquí también
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

