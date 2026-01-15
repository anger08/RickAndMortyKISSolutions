//
//  Extension.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/14/26.
//

import SwiftUI

extension String {
    /// Returns the color associated with the state of a Rick and Morty character.
    var statusColor: Color {
        switch self.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        default:
            return .orange
        }
    }
}
