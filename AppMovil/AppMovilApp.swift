//
//  AppMovilApp.swift
//  AppMovil
//
//  Created by DAMII on 14/12/24.
//

import SwiftUI

@main
struct AppMovilApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
