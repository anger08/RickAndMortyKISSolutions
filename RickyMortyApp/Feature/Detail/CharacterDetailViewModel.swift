//
//  CharacterDetailViewModel.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Foundation
import Factory
import Observation
import SwiftUI

@Observable @MainActor
final class CharacterDetailViewModel {
    @ObservationIgnored @Injected(\.getCharacterUseCase) var getCharacterUseCase: GetCharacterUseCase

    var character: Character?
    var isLoading: Bool = false
    var error: Error?

    let characterId: Int

    init(characterId: Int) {
        self.characterId = characterId
    }

    func loadCharacter() async {
        isLoading = true
        error = nil
        
        do {
            let fetchedCharacter = try await getCharacterUseCase.invoke(id: characterId)

            self.character = fetchedCharacter
            self.isLoading = false
        } catch {
            self.error = error
            self.isLoading = false
        }
    }

    func retry() async {
        await loadCharacter()
    }
  
    var episodeCount: Int {
        character?.episode.count ?? 0
    }
}
