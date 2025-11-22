//
//  ApiFetchingState.swift
//  BBQuotes
//
//  Created by Moataz on 19/10/2025.
//

enum ApiFetchingState: Equatable {
    case initial
    case loading
    case success
    case failure(String)
    
    static func == (lhs: ApiFetchingState, rhs: ApiFetchingState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
            (.loading, .loading),
            (.success, .success):
            return true
        case (.failure(let lError), .failure(let rError)):
            return lError == rError
        default:
            return false
        }
    }
}
