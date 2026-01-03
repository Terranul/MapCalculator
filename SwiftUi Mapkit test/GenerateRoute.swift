//
//  GenerateRoute.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2025-12-23.
//

import MapKit
import CoreLocation
import SwiftUI
internal import Combine

class GenerateRoute: ObservableObject {
    
    @Published var route: [Route] = []
    
    func generateRoutes(locations: [Location]) async throws {
        
        guard locations.count >= 2 else {
            // we just want to throw something to specify a route has not been fully built yet
            throw NSError()
        }
        
        var routes: [Route] = []
        
        for i in 1..<locations.count {
            let route = await Route(source: locations[i-1], destination: locations[i])
            routes.append(route)
        }
        route = routes
    }
    
    func hasData() -> Bool {
        return !(route.isEmpty)
    }
    
}
