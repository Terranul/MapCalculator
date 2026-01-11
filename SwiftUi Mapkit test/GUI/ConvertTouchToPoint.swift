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
    @StateObject private var tracker: DayTracker = DayTracker.getInstance(internalSelect: "Mon")
    
    @State private var position: MapCameraPosition =
        .camera(
            MapCamera(
                centerCoordinate: CLLocationCoordinate2D(
                    latitude: 49.2606,
                    longitude: -123.2460
                ),
                distance: 2_000
            )
        )
    
    var body: some View {
        VStack {
            MapReader { reader in
                ZStack(alignment: .top) {
                    Map(position: $position) {
                        ForEach(tracker.getData()) { location in
                            Marker("\(location.label) \n \(location.arrivalTime ?? "") - \(location.exitTime)", coordinate: location.coord)
                        }
                        ForEach(tracker.currentRoutes) { route in
                            MapPolyline(route.path!)
                                .stroke(tracker.getSelectedRoute() != nil && route == tracker.getSelectedRoute()! ? .blue : .gray, lineWidth: 4)
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
                        HStack(alignment: .top) {
                            SelectablePicker()
                                .environmentObject(tracker)
                            Spacer()
                            NavigationLink {
                                FileAccess()
                            } label: {
                                Text("Add File")
                            }
                            
                        }
                        Spacer()
                        if let route = tracker.getSelectedRoute() {
                            RouteCard(route: route, tracker: tracker)
                                .padding(10)
                                .backgroundStyle(.black)
                        }
                    }
                }
            }
        }
        .task(id: tracker.currentSelection) {
            do {
                try await tracker.generateRoutes()
                print("entered task")
            } catch {
                print("Unable to display route information, or not enough points available yet")
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}
