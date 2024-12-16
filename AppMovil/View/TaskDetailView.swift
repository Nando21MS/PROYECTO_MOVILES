//
//  TaskDetailView.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI

struct TaskDetailView: View {
    @State private var title: String
    @State private var reminderDate: Date?
    @State private var setReminder: Bool = false  // Nueva propiedad para habilitar/deshabilitar recordatorio
    @Environment(\.dismiss) var dismiss

    let onSave: (String, Date?) -> Void
    let onCancel: () -> Void

    init(task: TaskEntity? = nil, onSave: @escaping (String, Date?) -> Void, onCancel: @escaping () -> Void) {
        self._title = State(initialValue: task?.title ?? "")
        self._reminderDate = State(initialValue: task?.reminderDate)
        self._setReminder = State(initialValue: task?.reminderDate != nil)  // Si ya tiene recordatorio, lo marcamos como activado
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack {
            TextField("Enter task title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Toggle(isOn: $setReminder) {
                Text("Set Reminder")
            }
            .padding()

            if setReminder {
                DatePicker(
                    "Set Reminder",
                    selection: Binding(
                        get: { reminderDate ?? Date() },
                        set: { reminderDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .padding()
            }

            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Save") {
                    onSave(title, setReminder ? reminderDate : nil)  // Solo pasa el recordatorio si está activado
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
    }
}
