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
    @Environment(\.dismiss) var dismiss

    let onSave: (String, String, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title").font(.headline)) {
                    TextField("Enter note title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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

                Button(action: {
                    onSave(title, details, category)
                    dismiss()
                }) {
                    Text("Save Note")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Note")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
