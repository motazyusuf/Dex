//
//  Persistence.swift
//  Dex
//
//  Created by Moataz on 21/11/2025.
//

import CoreData

struct PersistenceController {
    static let shared: PersistenceController = PersistenceController()
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
//        
//        let newPokemon = Dex(context: viewContext)
//        newPokemon.id = 1
//        newPokemon.name = "bulbasaur"
//        newPokemon.types = ["grass", "poison"]
//        newPokemon.hp = 45
//        newPokemon.attack = 49
//        newPokemon.defense = 49
//        newPokemon.specialAttack = 65
//        newPokemon.specialDefense = 65
//        newPokemon.speed = 45
//        newPokemon.frontDefault = URL(
//            string:
//                "https://raw.githubusercontentcom/PokeAPI/sprites/master/sprites/pokemon/1.png"
//        )
//        newPokemon.frontShiny = URL(
//            string:
//                "https://raw.githubusercontentcom/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png"
//        )
//        
        do {
            try viewContext.save()
        } catch {
            print(error)
            
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        
        
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                print(error)
            }
        })
        
        container.viewContext.mergePolicy =
        NSMergePolicy.overwrite
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
