//
//  NetworkContainer.swift
//  RickyMortyApp
//
//  Created by Angelber Castro on 1/12/26.
//

import Factory

extension Container{
    var homeRemoteDataSource: Factory<HomeRemoteDtaSource> {
        Factory(self) { HomeRemoteDtaSourcelmpl() }
    }
}
