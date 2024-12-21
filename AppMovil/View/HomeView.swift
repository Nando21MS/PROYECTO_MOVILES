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
            ZStack {
                TabView {
                    NavigationView {
                        TaskListView(viewContext: viewContext, isLoggedOut: $isLoggedOut)
                            .navigationBarTitle("Tasks", displayMode: .inline)
                    }
                    .tabItem {
                        Label("Tasks", systemImage: "checkmark.circle")
                    }
                    
                    NavigationView {
                        PerfilView(isLoggedOut: $isLoggedOut)
                            .navigationBarTitle("Perfil", displayMode: .inline)
                    }
                    .tabItem {
                        Label("Perfil", systemImage: "person.circle")
                    }
                    
                    NavigationView {
                        NoteListView()
                            .navigationBarTitle("Notes", displayMode: .inline)
                    }
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }
                }
                .zIndex(1)
            }
        }
    }
}

#Preview {
    HomeView(username: "Usuario de Prueba")
}
