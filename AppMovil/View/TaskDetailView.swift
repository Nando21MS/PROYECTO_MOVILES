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
    @State private var titleIsValid = true  // Para controlar la validez del título

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
            // Campo de texto para el título de la tarea
            TextField("Enter task title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(titleIsValid ? Color.clear : Color.red.opacity(0.2))
                .cornerRadius(8)
                .onChange(of: title) { newValue in
                    titleIsValid = !newValue.isEmpty
                }

            // Toggle para activar/desactivar el recordatorio
            Toggle(isOn: $setReminder) {
                Text("Set Reminder")
            }
            .padding()

            // Mostrar el selector de fecha si el recordatorio está activado
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
                // Botón de cancelación
                Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.red)

                Spacer()

                // Botón de guardar
                Button("Save") {
                    // Validar si el título está vacío
                    if title.isEmpty {
                        alertMessage = "Title is required."
                        titleIsValid = false
                        showAlert = true
                    } else if setReminder, let reminderDate = reminderDate, reminderDate <= Date() {
                        // Solo validamos la fecha del recordatorio si está activado
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
            Alert(title: Text("Validation Error"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}
