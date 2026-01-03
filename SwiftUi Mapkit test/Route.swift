//
//  Route.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-02.
//

import SwiftUI
import MapKit
import CoreLocation

struct Location: Identifiable, Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.time == rhs.time
    }
    // CLLocationCoordinate2D doesn't conform to equatable or hashable, which means we need an extra struct for iteration
    let id = UUID()
    let coord: CLLocationCoordinate2D
    let time: String
    let label: String
}

struct Route: Identifiable {
    let id = UUID()
    let source: Location
    let destination: Location
    let path: MKRoute?
    
    init(source: Location, destination: Location) async {
        self.source = source
        self.destination = destination
        self.path = await Route.generatePath(source: source, destination: destination)
    }
    
    public static func generatePath(source: Location, destination: Location) async -> MKRoute? {
        let request = generateRequest(point1: MKPlacemark(coordinate: source.coord), point2: MKPlacemark(coordinate: destination.coord))
        do {
            let response = try await calculateRoutes(request)
            return response.routes.first!
        } catch {
            print("Could not generate a path from \(source.time) to \(destination.time)")
        }
        return nil
    }
    
    private static func generateRequest(point1: MKPlacemark, point2: MKPlacemark) -> MKDirections.Request {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: point1)
        request.destination = MKMapItem(placemark: point2)
        request.transportType = .walking
        
        return request
    }
    
    private static func calculateRoutes(_ request: MKDirections.Request) async throws -> MKDirections.Response {
        let directionsManager = MKDirections(request: request)
        return try await directionsManager.calculate()
    }
    
    public func distance() -> String {
        // distance is specified in meters, so we must convert to kilometers
        let distance = path!.distance
        return "\(distance/1000)km"
    }
    
    public func travelTime() -> String {
        // travelTime is specified in seconds, so we must convert to hours and minutes
        let travelTime = path!.expectedTravelTime
        let hours = Int(travelTime) / 3600
        let minutes = (Int(travelTime) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    // calculates the difference of the time between the source and destination of the route, and the actual calculated
    // travel time of the MKRoute
    public func calculateExcessTime() -> String {
        let formatter = FormatTime()
        let sourceDate = formatter.convert(time: destination.time)
        let interval: Double = sourceDate.timeIntervalSince(formatter.convert(time: source.time))
        let excessTime: Int = Int(interval - path!.expectedTravelTime)
        return "\(excessTime / 60)m \(excessTime % 60)s"
    }
 }
