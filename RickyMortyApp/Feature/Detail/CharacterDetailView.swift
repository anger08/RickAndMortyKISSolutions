//
//  CharacterDetailView.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import SwiftUI

struct CharacterDetailView: View {
    @State private var viewModel: CharacterDetailViewModel

    init(characterId: Int) {
        _viewModel = State(initialValue: CharacterDetailViewModel(characterId: characterId))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black, Color(red: 0.0, green: 0.3, blue: 0.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView(message: "Loading character...")
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.retry()
                    }
                }
            } else if let character = viewModel.character {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection(character: character)

                        infoSection(character: character)

                        locationsSection(character: character)

                        episodesSection(character: character)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .task {
            await viewModel.loadCharacter()
        }
    }

    @ViewBuilder
    private func headerSection(character: Character) -> some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 200, height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 80))
                        .frame(width: 200, height: 200)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(Color.green, lineWidth: 3)
            }
            .shadow(color: Color.green.opacity(0.5), radius: 12)

            Text(character.name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 20)
    }

    @ViewBuilder
    private func infoSection(character: Character) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Information")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }

            VStack(spacing: 16) {
                // Status
                DetailInfoRow(
                    title: "Status",
                    value: character.status,
                    icon: "circle.fill",
                    iconColor: character.status.statusColor
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Species
                DetailInfoRow(
                    title: "Species",
                    value: character.species,
                    icon: "pawprint.fill",
                    iconColor: .orange
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Gender
                DetailInfoRow(
                    title: "Gender",
                    value: character.gender,
                    icon: "person.fill",
                    iconColor: .purple
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private func locationsSection(character: Character) -> some View {
        VStack(spacing: 16) {

            HStack {
                Text("Locations")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }

            VStack(spacing: 16) {
                // Origin
                DetailInfoRow(
                    title: "Origin",
                    value: character.origin.name,
                    icon: "globe",
                    iconColor: .blue
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Current location
                DetailInfoRow(
                    title: "Current location",
                    value: character.location.name,
                    icon: "mappin.circle.fill",
                    iconColor: .red
                )
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private func episodesSection(character: Character) -> some View {
        VStack(spacing: 16) {

            HStack {
                Text("Episodes")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "tv.fill")
                        .foregroundColor(.cyan)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("It appears in \(viewModel.episodeCount) episodes")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("This character has appeared in \(viewModel.episodeCount) episode\(viewModel.episodeCount != 1 ? "s" : "")")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CharacterDetailView(characterId: 1)
    }
}
