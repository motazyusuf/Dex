//
//  ProductionEnum.swift
//  BBQuotes
//
//  Created by Moataz on 19/10/2025.
//
import Foundation
import SwiftUI

enum ProductionType: String, CaseIterable, Identifiable{
    var id: Self { self } 

    
    case breakingBad = "Breaking Bad"
    case betterCallSaul = "Better Call Saul"
    case elCamino = "El Camino"
    
 
    
    var tabIcon: String {
        switch self {
        case .breakingBad:
            "tortoise"
        case .betterCallSaul:
            "briefcase"
        case .elCamino:
            "car"
        }
    }
    
}
