//
//  opdsreaderApp.swift
//  opdsreader
//
//  Created by Николай Попов on 02.01.2023.
//

import SwiftUI

@main
struct opdsreaderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
