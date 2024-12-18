import SwiftUI

struct HomeView: View {
    var username: String
    
    @State private var isLoggedOut = false // Estado para controlar el estado de sesión
    @Environment(\.managedObjectContext) private var viewContext // Acceder al viewContext desde el Environment

    var body: some View {
        if isLoggedOut {
            // Cuando el usuario está deslogueado, mostrar LoginView a pantalla completa
            LoginView(isLoggedOut: $isLoggedOut)
                .transition(.move(edge: .leading)) // Animación de deslizamiento
        } else {
            TabView {
                TaskListView(viewContext: viewContext) // Pasar el viewContext aquí
                    .tabItem {
                        Label("Tasks", systemImage: "checkmark.circle")
                    }
                PerfilView(isLoggedOut: $isLoggedOut) // Pasar el estado de login a la vista de perfil
                    .tabItem {
                        Label("Perfil", systemImage: "person.circle")
                    }
                NoteListView()
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }
            }
        }
    }
}

#Preview {
    HomeView(username: "Usuario de Prueba")
}
