//
//  RepoContainer+Extnesions.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Factory

extension Container {
    var homeRepository: Factory<HomeRepository> {
        Factory(self) { HomeRepositorylmpl() }
    }
}
