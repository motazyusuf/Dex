//
//  ContentView.swift
//  Pokemon
//
//  Created by Moataz on 20/11/2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel
    
    // Accept context as parameter, default to shared for app
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            repo: PokemonRepo(),
            context: context
        ))
    }
 
      
    var body: some View {
         
        switch viewModel.pokemonsState {
        case .success:
            NavigationView {
                List {
                    ForEach(viewModel.pokemons) { item in
                        NavigationLink {
                            Text("Pokemon")
                        } label: {
                            Text(item.name ?? "Unknown")
                        }
                    }
                }
                
                Text("Select an item")
            }
        case .failure(let error):
            Text(error)
            
            default:
            ProgressView()

        }
       
    }
}

#Preview {
    // Pass preview context explicitly
    HomeView(context:  PersistenceController.preview.container.viewContext)
}
