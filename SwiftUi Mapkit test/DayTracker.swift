//
//  DayTracker.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-05.
//

import SwiftUI
internal import Combine
import CoreLocation

class DayTracker: ObservableObject {
    
    // the dayTracker and FormatTime should realisticly be combined, but this class was a late addition
    
    @Published private(set) var currentSelection: [Location] = []
    @Published private(set) var selectedRoute: Int = 0
    @Published public var currentRoutes: [Route] = []
    @Published private(set) var internalSelect: String
    private var data: [String : [Location]] = [ : ]
    
    init(internalSelect: String) {
        self.internalSelect = internalSelect
    }
    
    func addData(value: Location) {
        var curValue: [Location] = data[internalSelect, default: []]
        curValue.append(value)
        // reorder after every addition
        let formatter = FormatTime()
        let orderedSelection = formatter.convertLocations(locations: curValue)
        data[internalSelect] = orderedSelection
        currentSelection = orderedSelection
    }
    
    func isValidTime(value: String) -> Bool{
        let formatter = FormatTime()
        return formatter.isValidTime(time: value)
    }
    
    func swapSelection(value: String) {
        internalSelect = value
        currentSelection = data[internalSelect, default: []]
        selectedRoute = 0
    }
    
    func incrementRouteSelection() {
        if selectedRoute < currentRoutes.count - 1 {
            selectedRoute += 1
        }
    }
    
    func decrementRouteSelection() {
        if selectedRoute > 0 {
            selectedRoute -= 1
        }
    }
    
    func getSelectedRoute() -> Route? {
        if (selectedRoute < currentRoutes.count && selectedRoute >= 0 && currentSelection.count >= 2) {
            return currentRoutes[selectedRoute]
        }
        return nil
    }
    
    func getData() -> [Location] {
        return data[internalSelect, default: []]
    }
    
    func getSelection() -> String {
        return internalSelect
    }
    
    func generateRoutes() async throws {
        print("Updating routes!")
        
        let locations = data[internalSelect, default: []]
        var routes: [Route] = []
        
        guard locations.count >= 2 else {
            let dummyRoute = await getDummyRoute()
            routes.append(dummyRoute)
            currentRoutes = routes
            // we just want to throw something to specify a route has not been fully built yet
            throw NSError()
        }
        
        for i in 1..<locations.count {
            let route = await Route(source: locations[i-1], destination: locations[i])
            routes.append(route)
        }
        
        await MainActor.run() {
            currentRoutes = routes
        }
    }
    
    func hasRouteData() -> Bool {
        return !(currentRoutes.isEmpty)
    }
    
    func getDummyRoute() async -> Route {
        let source = Location(coord: CLLocationCoordinate2D(latitude: 55.75700, longitude: 37.62000), time: "12:00", label: "dummy")
        let destination = Location(coord: CLLocationCoordinate2D(latitude: 55.74790, longitude: 37.62000), time: "13:00", label: "dummy#2")
        return await Route(source: source, destination: destination)
    }
}
