//
//  FilterChip.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/13/26.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? Color(red: 0.2, green: 0.6, blue: 0.2)
                        : Color.white.opacity(0.1)
                )
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected
                                ? Color(red: 0.2, green: 0.6, blue: 0.2)
                                : Color.white.opacity(0.3),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }
}

