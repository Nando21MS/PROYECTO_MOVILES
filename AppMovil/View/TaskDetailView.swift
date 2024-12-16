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
    @State private var showAlert = false  // Para controlar la alerta
    @State private var alertMessage = ""  // Mensaje de la alerta

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
                    // Verificar si la fecha y hora del recordatorio es mayor a la fecha y hora actuales
                    if let reminderDate = reminderDate, reminderDate <= Date() {
                        alertMessage = "The reminder date and time must be in the future."
                        showAlert = true
                    } else {
                        // Si todo es correcto, guardar la tarea
                        onSave(title, setReminder ? reminderDate : nil)  // Solo pasa el recordatorio si está activado
                    }
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Date/Time"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}
