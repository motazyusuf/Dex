//
//  CharacterModel.swift
//  BBQuotes
//
//  Created by Moataz on 18/10/2025.
//

import Foundation

struct PokemonModel: Decodable, Equatable {
    let id: Int16?
    let name: String?
    var speed: Int16?
    var attack: Int16?
    var specialAttack: Int16?
    var defense: Int16?
    var specialDefense: Int16?
    var hp: Int16?
    let favorite: Bool?
    let frontShiny: URL?
    let frontDefault: URL?
    let types: [String]?

    enum CodingKeys: CodingKey {
        case id
        case name
        case speed
        case attack
        case specialAttack
        case defense
        case specialDefense
        case hp
        case favorite
        case frontShiny
        case frontDefault
        case types
    }

    init(
        name: String? = nil,
        id: Int16? = nil,
        speed: Int16? = nil,
        attack: Int16? = nil,
        specialAttack: Int16? = nil,
        defense: Int16? = nil,
        specialDefense: Int16? = nil,
        hp: Int16? = nil,
        favorite: Bool? = nil,
        frontShiny: URL? = nil,
        frontDefault: URL? = nil,
        types: [String]? = nil
    )
    {
        self.name = name
        self.id = id
        self.speed = speed
        self.attack = attack
        self.specialAttack = specialAttack
        self.defense = defense
        self.specialDefense = specialDefense
        self.hp = hp
        self.favorite = favorite
        self.frontShiny = frontShiny
        self.frontDefault = frontDefault
        self.types = types
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        
        name = container.safeStringDecode(forKey: .name)
        id = container.safeNumDecode(forKey: .id)
        if let stats = decoder.safeObjectDecode(["stats"]) as [statsData]? {
            hp = stats[safe: 0]?.stat
            attack = stats[safe: 1]?.stat
            defense = stats[safe: 2]?.stat
            specialAttack = stats[safe: 3]?.stat
            specialDefense = stats[safe: 4]?.stat
            speed = stats[safe: 5]?.stat
        }
        favorite = container.safeBoolDecode(forKey: .favorite)
        frontShiny = container.safeURLDecode(forKey: .frontShiny)
        frontDefault = decoder.safeURLDecode(["sprites", "frontDefault"])
        types = (container.safeObjectDecode(forKey: .types) as [typeData]?)?.compactMap { $0.type}
        
        // create a loop to print all value
        
        let debugValues: [String: Any?] = [
            "name": name,
            "id": id,
            "hp": hp,
            "attack": attack,
            "defense": defense,
            "specialAttack": specialAttack,
            "specialDefense": specialDefense,
            "speed": speed,
            "favorite": favorite,
            "frontShiny": frontShiny,
            "frontDefault": frontDefault,
            "types": types
        ]
        
        debugValues.forEach { key, value in
            print("\(key): \(value ?? "nil")")
        }
        
        
    }
}

struct typeData: Decodable, Equatable {
    let type: String?
    init(from decoder: Decoder) throws {
        type = decoder.safeStringDecode(["type", "name"])
    }
}

struct statsData: Decodable, Equatable {
    let stat: Int16?
    init(from decoder: Decoder) throws {
        stat = decoder.safeNumDecode(["base_stat"])
    }
}


// for sub-getting the stats

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
