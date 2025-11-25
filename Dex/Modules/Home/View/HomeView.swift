//
//  ContentView.swift
//  Pokemon
//
//  Created by Moataz on 20/11/2025.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var searchText: String = ""
    
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
            NavigationStack {
                List {
                    ForEach(viewModel.modifiedPokemons) { pokemon in
                        NavigationLink(value: pokemon) {
                            AsyncImageWithProgress(imageUrl: pokemon.frontDefault)
                                .scaledToFit()
                                .frame(width: 100, height: 150)
                            
                            VStack(alignment: .leading) {
                                Text(pokemon.name?.capitalized ?? "")
                                    .fontWeight(.bold)
                                
                                HStack{
                                    ForEach(pokemon.types!, id: \.self) { type in
                                        
                                        Text(type.capitalized)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.black)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(Color(type.capitalized))
                                            .clipShape(.capsule)
                                     }

                                }
                            }
                          }
                    }
                }
                .navigationTitle("PokeDex")
                .searchable(text: $searchText , prompt: "Search Pokemon")
                .onChange(of: searchText) {
                    withAnimation {
                        viewModel.searchPokemons(searchText: searchText)
                    }
                }
                .autocorrectionDisabled()
                .navigationDestination(for: Dex.self) { pokemon in
                    PokemonDetailsView(pokemon: pokemon)
                }
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
    HomeView(context: PersistenceController.preview.container.viewContext)
}

struct AsyncImageWithProgress: View {
    let imageUrl: URL?
    
    var body: some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
        }
        placeholder: {
            ProgressView()
        }
    }
}
