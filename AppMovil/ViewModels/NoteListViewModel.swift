//
//  NoteListViewModel.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import Foundation
import CoreData

class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    private var context: NSManagedObjectContext = PersistenceController.shared.container.viewContext

    init() {
        fetchAllNotes()
    }

    func addNote(title: String, details: String? = nil, category: String? = nil) {
        let note = Note(context: context)
        note.title = title
        note.details = details
        note.category = category
        print("Note created with title: \(title), details: \(details ?? "No details"), category: \(category ?? "No category")")
        saveContext()
        fetchAllNotes()
    }


    func deleteNote(note: Note) {
        context.delete(note)
        saveContext()
        fetchAllNotes()
    }

    func fetchAllNotes() {
        let request = Note.fetchAllNotesRequest()
        do {
            notes = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateNote(note: Note) {
        saveContext() // Guarda los cambios
        fetchAllNotes() // Vuelve a cargar las notas
    }
}
