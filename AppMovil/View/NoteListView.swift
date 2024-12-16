//
//  NoteListView.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI

struct NoteListView: View {
    @StateObject private var viewModel = NoteListViewModel()
    @State private var selectedCategory: String = "All"
    @State private var showingNewNote = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Filtro de categorías
                    Picker("Category", selection: $selectedCategory) {
                        Text("All").tag("All")
                        Text("Work").tag("Work")
                        Text("Study").tag("Study")
                        Text("Personal").tag("Personal")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    // Listado de Notas
                    List {
                        ForEach(filteredNotes) { note in
                            // Fila individual
                            HStack {
                                // Enlace para editar la nota
                                NavigationLink(destination: NoteDetailView(note: note, onSave: { updatedNote in
                                    viewModel.updateNote(note: updatedNote)
                                })) {
                                    VStack(alignment: .leading) {
                                        Text(note.title ?? "Untitled")
                                            .font(.headline)
                                        if let details = note.details, !details.isEmpty {
                                            Text(details)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                        if let category = note.category {
                                            Text(category)
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(categoryColor(category))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .contentShape(Rectangle()) // Asegura que el toque sea claro

                                Spacer()

                                // Botón de eliminar, separado del NavigationLink
                                Button(action: {
                                    viewModel.deleteNote(note: note)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle()) // Evita conflictos de gestos
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { viewModel.deleteNote(note: filteredNotes[$0]) }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                // Botón flotante para agregar nota
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingNewNote.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Notes")
            .sheet(isPresented: $showingNewNote) {
                NewNoteView(onSave: { title, details, category in
                    viewModel.addNote(title: title, details: details, category: category)
                    showingNewNote = false
                })
            }
            .onAppear {
                viewModel.fetchAllNotes()
            }
        }
    }

    // Filtro para mostrar notas según la categoría seleccionada
    private var filteredNotes: [Note] {
        if selectedCategory == "All" {
            return viewModel.notes
        } else {
            return viewModel.notes.filter { $0.category == selectedCategory }
        }
    }

    // Asigna colores según la categoría
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "Work": return Color.blue
        case "Study": return Color.green
        case "Personal": return Color.purple
        default: return Color.gray
        }
    }
}

#Preview {
    NoteListView()
}
