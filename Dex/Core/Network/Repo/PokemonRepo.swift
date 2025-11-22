//
//  PokemonRepo.swift
//  Pokemon
//
//  Created by Moataz on 20/11/2025.
//


import Foundation

struct PokemonRepo {
    
    
    func getData(id: Int) async throws -> (PokemonModel,HTTPURLResponse) {
        
        let response = try await NetworkHelper.request(
            url: URL(string: "\(Api.pokemon)/\(id)")!,
            method: .get,
            responseType: PokemonModel.self,
        )
        
        return response
        
    }
    
    
}
