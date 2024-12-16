//
//  HomeView.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext // Acceder al viewContext desde el Environment

    var body: some View {
        TabView {
            TaskListView(viewContext: viewContext)  // Pasar el viewContext aquí
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }
            NoteListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
        }
    }
}

#Preview {
    HomeView()
}




