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
    
    // tapped coordinates to be displayed on the map
    @State public var coords: [Location] = []
    @State private var curLabel: String = ""
    @State public var selectedCoordinate: CLLocationCoordinate2D?
    @State public var showTextField: Bool = false
    @State private var selectedRouteIndex = 0
    
    @StateObject private var generator: GenerateRoute = GenerateRoute()
    private var formatter: FormatTime = FormatTime()
    
    var body: some View {
        VStack {
            MapReader { reader in
                ZStack(alignment: .top) {
                    Map() {
                        ForEach(coords) { location in
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
                            CoordinateSelectionView(coords: $coords, showTextField: $showTextField, selectedCoordinate: $selectedCoordinate)
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
        .task(id: coords) {
            do {
                try await generator.generateRoutes(locations: coords)
                print("entered task")
            } catch {
                print("Unable to display route information, or not enough points available yet")
            }
        }
    }
}
