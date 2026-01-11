//
//  DecodeLocations.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-07.
//

struct MapLocation: Decodable {
    let latitude: String
    let longitude: String
}

struct MapLocations: Decodable {
    let locations: [String: Map]
}

class DecodeLocations {
    
}
