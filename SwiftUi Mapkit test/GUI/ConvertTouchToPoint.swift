//
//  ConvertTouchToPoint.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2025-12-22.
//

import SwiftUI
import CoreLocation
import MapKit

struct ConvertTouchToPoint: View {
    
    @State private var curLabel: String = ""
    @State public var selectedCoordinate: CLLocationCoordinate2D?
    @State public var showTextField: Bool = false
    @State private var selectedRouteIndex = 0
    
    @StateObject private var generator: GenerateRoute = GenerateRoute()
    @StateObject private var tracker: DayTracker = DayTracker(internalSelect: "M")
    
    var body: some View {
        VStack {
            MapReader { reader in
                ZStack(alignment: .top) {
                    Map() {
                        ForEach(tracker.getData()) { location in
                            Marker(location.label, coordinate: location.coord)
                        }
                        if (generator.hasData()) {
                            ForEach(generator.route.indices, id: \.self) { index in
                                MapPolyline(generator.route[index].path!)
                                    .stroke(index == selectedRouteIndex ? .blue : .gray, lineWidth: 4)
                            }
                        }
                    }
                    .onTapGesture() { coord in
                        let mapCoord = reader.convert(coord, from: .local)
                        selectedCoordinate = mapCoord
                        showTextField = true
                    }
                    .mapControls {
                        MapCompass(scope: .none)
                    }
                    VStack {
                        if (showTextField) {
                            CoordinateSelectionView(showTextField: $showTextField, selectedCoordinate: $selectedCoordinate, tracker: tracker)
                                .padding(10)
                        }
                        Spacer()
                        if generator.hasData() {
                            RouteCard(route: $generator.route[selectedRouteIndex], selectedIndex: $selectedRouteIndex)
                                .padding(10)
                                .backgroundStyle(.black)
                        }
                    }
                }
            }
        }
        .task(id: tracker.currentSelection) {
            do {
                try await generator.generateRoutes(locations: tracker.getData())
                print("entered task")
            } catch {
                print("Unable to display route information, or not enough points available yet")
            }
        }
    }
}
