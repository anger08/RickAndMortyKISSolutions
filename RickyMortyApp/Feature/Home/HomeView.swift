//
//  HomeView.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var path = NavigationPath()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.black, Color(red: 0.0, green: 0.3, blue: 0.0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                contentView
            }
            .navigationTitle("Rick and Morty")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .navigationDestination(for: Int.self) { characterId in
                CharacterDetailView(characterId: characterId)
            }
            .task {
                if viewModel.characters.isEmpty && !viewModel.isLoading {
                    await viewModel.loadCharacters()
                }
            }
        }
    }

    // MARK: - Search & Filter Section

    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))

                TextField("Find a character...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(CharacterStatus.allCases) { status in
                        FilterChip(
                            title: status.rawValue,
                            isSelected: viewModel.selectedStatus == status
                        ) {
                            viewModel.selectedStatus = status
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.characters.isEmpty && !viewModel.shouldShowNotFoundMessage {
            LoadingView(message: "")
        } else if let error = viewModel.error,
                    viewModel.characters.isEmpty,
                    !viewModel.shouldShowNotFoundMessage,
                  viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty || !viewModel.isNotFoundError {
            ErrorView(error: error) {
                Task {
                    await viewModel.retry()
                }
            }
        } else if viewModel.shouldShowNotFoundMessage {
            // View with search bar visible and "not found" message
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    searchAndFilterSection
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))

                        VStack(spacing: 8) {
                            Text("No characters were found")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("There are no characters that match with \"\(viewModel.searchText)\"")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                }
            }
        }else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    searchAndFilterSection
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.characters) { character in
                            Button {
                                path.append(character.id)
                            } label: {
                                CharacterRow(character: character)
                                    .onAppear {
                                        if viewModel.shouldLoadMore(currentItem: character) {
                                            Task {
                                                // We load the next page asynchronously
                                                await viewModel.loadNextPage()
                                            }
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }

                        // INFINITE SCROLL: Load indicator during paging
                        if viewModel.isLoading && !viewModel.characters.isEmpty {
                            ProgressView()
                                .tint(.white)
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .gridCellColumns(2)
                                .padding(.vertical, 20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .overlay(alignment: .bottom) {
                if let error = viewModel.error, !viewModel.characters.isEmpty {
                    ErrorView(error: error, style: .banner) {
                        Task {
                            await viewModel.retry()
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

