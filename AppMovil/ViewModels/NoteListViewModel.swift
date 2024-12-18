//
//  NoteListViewModel.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseAuth

class NoteListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    private var context: NSManagedObjectContext
    private var db = Firestore.firestore()

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAllNotes() // Inicializar con las notas
    }

    func addNote(title: String, details: String? = nil, category: String? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Usuario no autenticado")
            return
        }

        let noteId = UUID().uuidString

        // Crear la nota en Firestore
        let noteData: [String: Any] = [
            "noteId": noteId,
            "title": title,
            "details": details as Any,
            "category": category as Any,
            "createdAt": FieldValue.serverTimestamp(),
            "userId": userID
        ]

        db.collection("notes").document(userID).collection("users").document(noteId).setData(noteData) { error in
            if let error = error {
                print("Error al agregar nota: \(error.localizedDescription)")
            } else {
                print("Nota agregada correctamente")
                self.fetchAllNotes() // Refrescar la lista de notas
            }
        }
    }

    func deleteNote(note: Note) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let noteId = note.noteId else {
            print("Error: la nota no tiene un noteId asignado")
            return
        }

        // Eliminar nota de Firestore
        db.collection("notes").document(userID).collection("users").document(noteId).delete { error in
            if let error = error {
                print("Error al eliminar nota: \(error.localizedDescription)")
            } else {
                print("Nota eliminada correctamente")
                self.fetchAllNotes()
            }
        }
    }

    func fetchAllNotes() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Obtener todas las notas de Firestore
        db.collection("notes").document(userID).collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener notas: \(error.localizedDescription)")
            } else {
                self.deleteAllNotesFromCoreData() // Eliminar notas existentes en Core Data

                self.notes = snapshot?.documents.compactMap { document in
                    let note = Note(context: self.context)
                    note.noteId = document.documentID // Asignar el ID del documento Firestore
                    note.title = document["title"] as? String ?? "Título desconocido"
                    note.details = document["details"] as? String
                    note.category = document["category"] as? String
                    self.saveContext()
                    return note
                } ?? []
            }
        }
    }

    private func deleteAllNotesFromCoreData() {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchAllNotesRequest()
        do {
            let notesInCoreData = try context.fetch(fetchRequest)
            for note in notesInCoreData {
                context.delete(note)
            }
            saveContext()
        } catch {
            print("Error al eliminar notas de Core Data: \(error.localizedDescription)")
        }
    }

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error al guardar contexto de Core Data: \(error.localizedDescription)")
            }
        }
    }

    func updateNote(note: Note) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let noteId = note.noteId else {
            print("Error: la nota no tiene un noteId asignado")
            return
        }

        // Actualizar la nota en Firestore
        db.collection("notes").document(userID).collection("users").document(noteId).updateData([
            "title": note.title,
            "details": note.details as Any,
            "category": note.category as Any
        ]) { error in
            if let error = error {
                print("Error al actualizar nota: \(error.localizedDescription)")
            } else {
                print("Nota actualizada correctamente")
                self.fetchAllNotes()
            }
        }
    }
}
