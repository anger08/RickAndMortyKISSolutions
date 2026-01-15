//
//  ErrorView.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/13/26.
//

import SwiftUI

enum ErrorViewStyle {
    case fullScreen
    case banner
}

struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    let style: ErrorViewStyle
    let title: String
    let buttonText: String
    let borderColor: Color
    
    init(
        error: Error,
        style: ErrorViewStyle = .fullScreen,
        title: String = "Error loading",
        buttonText: String = "Retry",
        borderColor: Color = .green,
        onRetry: @escaping () -> Void
    ) {
        self.error = error
        self.style = style
        self.title = title
        self.buttonText = buttonText
        self.borderColor = borderColor
        self.onRetry = onRetry
    }


    var body: some View {
        switch style {
        case .fullScreen:
            fullScreenView
        case .banner:
            bannerView
        }
    }
    
    // MARK: - Full Screen Style
    private var fullScreenView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                onRetry()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text(buttonText)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 2)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Banner Style
    private var bannerView: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                onRetry()
            } label: {
                Text(buttonText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(borderColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor.opacity(0.5), lineWidth: 1)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
}
