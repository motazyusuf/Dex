//
//  ContentView.swift
//  Pokemon
//
//  Created by Moataz on 20/11/2025.
//

import SwiftUI
import CoreData

struct PokemonDetailsView: View {
    
     let pokemon: Dex?
    
      
    var body: some View {
         
        VStack{
            
            AsyncImageWithProgress(imageUrl: pokemon?.frontDefault ?? URL(string: ""))
                .scaledToFit()
        }
       
    }
}

#Preview {
    PokemonDetailsView(pokemon: Dex())
}


