//
//  CoordinateSelectionView.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-03.
//

import SwiftUI
import MapKit

struct CoordinateSelectionView: View {
    
    @Binding public var coords: [Location]
    @State public var curLabel: String = ""
    @Binding public var showTextField: Bool
    @Binding public var selectedCoordinate: CLLocationCoordinate2D?
    @State public var time: String = ""
    public var formatter: FormatTime = FormatTime()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter location label", text: $curLabel)
                    .foregroundStyle(.black)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .stroke(Color.black, lineWidth: 2)
                    )
                TextField("Enter time", text: $time)
                    .keyboardType(.numbersAndPunctuation)
                    .padding(10)
                    .foregroundStyle(.black)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .stroke(Color.black, lineWidth: 2)
                    )
                Button {
                    if let selectedCoordinate {
                        if formatter.isValidTime(time: time) {
                            let curLocation = Location(coord: selectedCoordinate, time: time, label: curLabel)
                            coords.append(curLocation)
                            curLabel = ""
                            showTextField = false
                        } else {
                            time = "Invalid time (HH:MM)"
                        }
                    }
                    coords = formatter.convertLocations(locations: coords)
                } label: {
                    Image(.send)
                        .padding(5)
                }
                .foregroundStyle(Color.blue)
            }
        }
    }
}
