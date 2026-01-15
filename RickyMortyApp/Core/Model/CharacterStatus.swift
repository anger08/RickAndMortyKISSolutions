//
//  CharacterStatus.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/14/26.
//

import Foundation

// MARK: - CharacterStatus

enum CharacterStatus: String, CaseIterable, Identifiable {
    case all = "All"
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "Unknown"

    var id: String { rawValue }

    var apiValue: String? {
        self == .all ? nil : rawValue.lowercased()
    }
}
