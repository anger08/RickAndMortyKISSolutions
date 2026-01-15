//
//  DetailInfoRow.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/13/26.
//

import SwiftUI

struct DetailInfoRow: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}
