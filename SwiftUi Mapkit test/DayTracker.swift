//
//  DayTracker.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-05.
//

import SwiftUI
internal import Combine
import CoreLocation

struct Selection {
    // an internal struct representing the current overall selection of the user
}

// we can have multiple modifications concurrently by either the user or the parse courses
// we could use actor, but it would make all access async
// so, make sure to put anything mutating this class on the main thread
class DayTracker: ObservableObject {
    
    // the dayTracker and FormatTime should realisticly be combined, but this class was a late addition
    
    @Published private(set) var currentSelection: [Location] = []
    @Published public var currentRoutes: [Route] = []
    private var dataSem1: [String : [Location]] = [ : ]
    private var dataSem2: [String : [Location]] = [ : ]
    static var instance: DayTracker? = nil
    
    @Published private(set) var selectedRoute: Int // the index value of the selected route
    @Published private(set) var selectedDay: String // the day code of the selected day ("Mon, Tue, Wed, Thu, Fri, Sat, Sun")
    @Published private(set) var selectedSemester: String // the semester code of the selected semester ("Sem1, Sem2")
    
    init(selectedDay: String, selectedSemester: String) {
        self.selectedRoute = 0
        self.selectedDay = selectedDay
        self.selectedSemester = selectedSemester
    }
    
    public static func getInstance(selectedDay: String, selectedSemester: String) -> DayTracker  {
        if let instance {
            return instance
        } else {
            instance = DayTracker(selectedDay: selectedDay, selectedSemester: selectedSemester)
            return instance!
        }
    }
    
    private func getSelectedSemesterData() -> [String: [Location]] {
        switch(selectedSemester) {
        case "Sem 1":
            return dataSem1
        case "Sem 2":
            return dataSem2
        default:
            return dataSem1
        }
    }
    
    private func setSelectedSemesterData(value: [String: [Location]]) {
        switch (selectedSemester) {
        case "Sem 1":
            dataSem1 = value
        case "Sem 2":
            dataSem2 = value
        default:
            dataSem1 = value
        }
    }
    
    func addData(value: Location) {
        var curSemester: [String: [Location]] = getSelectedSemesterData()
        var curValue: [Location] = curSemester[selectedDay, default: []]
        curValue.append(value)
        // reorder after every addition
        let formatter = FormatTime()
        let orderedSelection = formatter.convertLocations(locations: curValue)
        curSemester[selectedDay] = orderedSelection
        setSelectedSemesterData(value: curSemester)
        currentSelection = orderedSelection
    }
    
    func isValidTime(value: String) -> Bool{
        let formatter = FormatTime()
        return formatter.isValidTime(time: value)
    }
    
    func swapSelection(value: String) {
        if (value == "Sem 1" || value == "Sem 2") {
            // this case we want to filter the semester selection
            selectedSemester = value
            currentSelection = getSelectedSemesterData()[selectedDay, default: []]
        } else {
            selectedDay = value
            currentSelection = getSelectedSemesterData()[selectedDay, default: []]
            selectedRoute = 0
        }
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
        return getSelectedSemesterData()[selectedDay, default: []]
    }
    
    func getDaySelection() -> String {
        return selectedDay
    }
    
    func generateRoutes() async throws {
        print("Updating routes!")
        
        let locations = getSelectedSemesterData()[selectedDay, default: []]
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
    
    func resetData() {
        dataSem1 = [ : ]
        dataSem2 = [ : ]
    }
    
    func hasRouteData() -> Bool {
        return !(currentRoutes.isEmpty)
    }
    
    func getSelectedSemester() -> String {
        return selectedSemester
    }
    
    func getDummyRoute() async -> Route {
        let source = Location(coord: CLLocationCoordinate2D(latitude: 55.75700, longitude: 37.62000), exitTime: "12:00", label: "dummy")
        let destination = Location(coord: CLLocationCoordinate2D(latitude: 55.74790, longitude: 37.62000), exitTime: "13:00", label: "dummy#2")
        return await Route(source: source, destination: destination)
    }
}
