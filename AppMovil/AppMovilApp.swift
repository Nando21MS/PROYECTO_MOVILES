//
//  AppMovilApp.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI
import FirebaseCore
@main
struct AppMovilApp: App {
    
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
        
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView(isLoggedOut: .constant(true))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
