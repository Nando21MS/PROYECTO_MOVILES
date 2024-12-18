//
//  DetailNoteView.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI

struct NoteDetailView: View {
    @State private var title: String
    @State private var details: String
    @State private var category: String
    @State private var titleIsValid: Bool = true  // Estado para validar el título
    @State private var showAlert: Bool = false  // Para mostrar la alerta si el título es inválido
    @State private var alertMessage: String = ""  // Mensaje de la alerta
    @Environment(\.dismiss) var dismiss

    let onSave: (Note) -> Void
    var note: Note

    init(note: Note, onSave: @escaping (Note) -> Void) {
        self._title = State(initialValue: note.title ?? "")
        self._details = State(initialValue: note.details ?? "")
        self._category = State(initialValue: note.category ?? "Work")
        self.note = note
        self.onSave = onSave
    }

    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Note Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: title) { newValue in
                        // Validar que el título no esté vacío
                        titleIsValid = !newValue.isEmpty
                    }
                    .background(titleIsValid ? Color.clear : Color.red.opacity(0.2))
                    .cornerRadius(8)
                
                // Si el título no es válido, mostramos un mensaje de error
                if !titleIsValid {
                    Text("Title is required")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }

            Section(header: Text("Details")) {
                TextEditor(text: $details)
                    .frame(height: 100)
            }

            Section(header: Text("Category")) {
                Picker("Category", selection: $category) {
                    Text("Work").tag("Work")
                    Text("Study").tag("Study")
                    Text("Personal").tag("Personal")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Edit Note")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Verificar si el título es válido antes de guardar
                    if title.isEmpty {
                        alertMessage = "Title is required."
                        showAlert = true
                    } else if titleIsValid {  // Solo guarda si el título es válido
                        note.title = title
                        note.details = details
                        note.category = category
                        onSave(note)
                        dismiss()
                    }
                }
                .disabled(title.isEmpty) // Deshabilitar el botón si el título está vacío
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}
