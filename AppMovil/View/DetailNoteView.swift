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
                    note.title = title
                    note.details = details
                    note.category = category
                    onSave(note)
                    dismiss()
                }
            }
        }
    }
}

