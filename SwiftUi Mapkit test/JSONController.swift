//
//  JSONController.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-09.
//

import Foundation

struct LocationSet: Decodable {
    let locations: [String : MapLoc]
}

struct MapLoc: Decodable {
    let latitude: Int
    let longitude: Int
}

class JSONController {
    
    func returnJsonData() throws -> Data {
        let bundle: Bundle = Bundle.main
        guard let url = bundle.url(forResource: "locations", withExtension: "json") else {
            fatalError("unable to access locations json")
        }
        return try Data(contentsOf: url)
    }
    
    func returnJSONMapping() -> [String : MapLoc] {
        do {
            let data: Data = try returnJsonData()
            let decoder = JSONDecoder()
            let set = try decoder.decode(LocationSet.self, from: data)
            return set.locations
        } catch {
            // bit of a hack, but will be sort of useful
            print("unable to correctly decode json data")
            return [:]
        }
    }
}
