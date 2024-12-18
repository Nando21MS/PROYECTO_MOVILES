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
                            // Fila individual con animación y efectos
                            HStack {
                                // Enlace para editar la nota
                                NavigationLink(destination: NoteDetailView(note: note, onSave: { updatedNote in
                                    viewModel.updateNote(note: updatedNote)
                                })) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(note.title ?? "Untitled")
                                            .font(.headline)
                                            .strikethrough(note.title == nil, color: .gray)
                                        
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
                                .contentShape(Rectangle())

                                Spacer()

                                // Botón de eliminar
                                Button(action: {
                                    withAnimation {
                                        viewModel.deleteNote(note: note)
                                    }
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .padding(10)
                                        .background(Circle().fill(Color.white).shadow(radius: 5))
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .opacity(note.title == nil ? 0.5 : 1.0)
                            .transition(.move(edge: .top))
                        }
                        .onDelete { indexSet in
                            withAnimation {
                                indexSet.forEach { viewModel.deleteNote(note: filteredNotes[$0]) }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                // Botón flotante para agregar nueva nota
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: NewNoteView(onSave: { title, details, category in
                            withAnimation {
                                viewModel.addNote(title: title, details: details, category: category)
                            }
                        })) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(15)
                                .background(Circle().fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                                .shadow(radius: 10)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
                .zIndex(1) // Asegura que el botón flotante esté encima de todo
            }
            .navigationTitle("Notes")
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                withAnimation {
                    viewModel.fetchAllNotes()
                }
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
