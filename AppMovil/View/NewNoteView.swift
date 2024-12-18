//
//  NewNoteView.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI

struct NewNoteView: View {
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var category: String = "Work"
    @State private var titleIsValid: Bool = true  // Estado para validar el título
    @State private var showAlert: Bool = false  // Para mostrar la alerta si el título es inválido
    @State private var alertMessage: String = ""  // Mensaje de la alerta
    @Environment(\.dismiss) var dismiss

    let onSave: (String, String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title").font(.headline)) {
                    TextField("Enter note title", text: $title)
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
                        .frame(height: 120)
                        .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.gray, lineWidth: 1))
                        .padding(.top, 8)
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
            .navigationTitle("New Note")
            .navigationBarItems(trailing: Button("Save") {
                if title.isEmpty {
                    alertMessage = "Title is required."
                    showAlert = true
                } else if titleIsValid {  // Solo guarda si el título es válido
                    onSave(title, details, category)
                    dismiss()  // Dismissing the view after saving
                }
            }
            .disabled(title.isEmpty)) // Deshabilitar el botón si el título está vacío
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Validation Error"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    NewNoteView(onSave: { title, details, category in
        print("Note saved with title: \(title), details: \(details), category: \(category)")
    })
}
