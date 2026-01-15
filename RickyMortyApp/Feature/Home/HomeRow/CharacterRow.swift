//
//  CharacterRow.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/14/26.
//

import SwiftUI

struct CharacterRow: View {
    let character: Character

    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 100, height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 100, height: 100)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())

            Text(character.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Status (Alive/Dead/Unknown)
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(character.status)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Species
            Text(character.species)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    .green,
                    lineWidth: 2
                )
        }
        .shadow(color: Color.green.opacity(0.4), radius: 8)
    }

    private var statusColor: Color {
        character.status.statusColor
    }
}

