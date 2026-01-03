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
    @State private var coords: [Location] = []
    @State private var curLabel: String = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showTextField: Bool = false
    @State private var selectedRouteIndex = 0
    
    @StateObject private var generator: GenerateRoute = GenerateRoute()
    private var formatter: FormatTime = FormatTime()
    
    var body: some View {
        VStack {
            MapReader { reader in
                ZStack(alignment: .top) {
                    Map() {
                        ForEach(coords) { location in
                            Annotation("", coordinate: location.coord) {
                                Text(location.label)
                            }
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
                    VStack {
                        if (showTextField) {
                            HStack {
                                TextField("Enter location label", text: $curLabel)
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                    )
                                Button {
                                    if let selectedCoordinate {
                                        let curLocation = Location(coord: selectedCoordinate, label: curLabel)
                                        coords.append(curLocation)
                                        curLabel = ""
                                    }
                                    coords = formatter.convertLocations(locations: coords)
                                    showTextField = false
                                } label: {
                                    Text("Ok")
                                        .padding(5)
                                }
                                .foregroundStyle(Color.blue)
                            }
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
