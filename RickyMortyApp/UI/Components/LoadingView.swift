//
//  LoadingView.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/13/26.
//

import SwiftUI

struct LoadingView: View {
    let message: String

    init(message: String) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)

            Text(message)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
