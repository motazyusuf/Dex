//
//  HomeVM.swift
//  Pokemon
//
//  Created by Moataz on 20/11/2025.
//

import Foundation

import CoreData

@MainActor
class HomeViewModel: ObservableObject {
    
    private let viewContext: NSManagedObjectContext
    private let repo: PokemonRepo
    private var state: ApiFetchingState {
        switch pokemonsState {
        case let .failure(message):
            return .failure(message)
            
        case .loading:
            return .loading
            
        case .success:
            return .success
            
        default:
            return .initial
        }
    }

    @Published var pokemons: [Dex] = []
    @Published var pokemonsState: ApiFetchingState = .initial
    

    init(repo: PokemonRepo, context: NSManagedObjectContext) {
        self.repo = repo
        self.viewContext = context

        Task {
            await getData()
        }
    }
    
    func getData() async {
        do {
            pokemonsState = .loading
            
            // ✅ Step 1: Try to load from cache first
            let existingPokemons = try viewContext.fetch(Dex.fetchRequest())
            
            if !existingPokemons.isEmpty {
                // ✅ We have cached data - use it!
                pokemons = existingPokemons
                pokemonsState = .success
                return
            }
            
            // ✅ Step 2: No cache - fetch from API
            for id in 1 ... 30 {
                let pokemon = Dex(context: viewContext)
                
                do {
                    let (data, httpResponse): (PokemonModel, HTTPURLResponse) =
                    try await repo.getData(id: id)
                    
                    if httpResponse.statusCode == 200 {
                        pokemon.id = Int16(data.id ?? 0)
                        pokemon.name = data.name
                        pokemon.attack = Int16(data.attack ?? 0)
                        pokemon.defense = Int16(data.defense ?? 0)
                        pokemon.frontDefault = data.frontDefault
                        pokemon.frontShiny = data.frontShiny
                        pokemon.speed = Int16(data.speed ?? 0)
                        pokemon.specialAttack = Int16(data.specialAttack ?? 0)
                        pokemon.specialDefense = Int16(data.specialDefense ?? 0)
                        pokemon.types = data.types
                        
                        pokemons.append(pokemon)
                    }
                } catch {
                    // Failed to fetch this pokemon - skip it
                    viewContext.delete(pokemon)  // Clean up the empty object
                    continue
                }
            }
            
            // ✅ Step 3: Save to Core Data for next time
            try viewContext.save()
            pokemonsState = .success
            
        } catch {
            print("❌ Request failed:", error)
            pokemonsState = .failure(error.localizedDescription)
        }
    }}
