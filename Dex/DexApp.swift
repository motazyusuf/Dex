//
//  DexApp.swift
//  Dex
//
//  Created by Moataz on 21/11/2025.
//


import SwiftUI

@main
struct PokemonApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView(context: persistenceController.container.viewContext)
        }
    }
}
