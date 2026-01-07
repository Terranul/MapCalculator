//
//  RouteCard.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-02.
//

import SwiftUI

struct RouteCard: View {
    
    public var route: Route
    @ObservedObject public var tracker: DayTracker
    
    var body: some View {
        VStack {
            Text("\(route.source.time) - \(route.destination.time)")
                .font(.headline)
                .foregroundStyle(.black)
            HStack {
                VStack (alignment: .center){
                    Text(route.travelTime())
                        .foregroundStyle(.black)
                    Text("Travel Time")
                        .foregroundStyle(.black)
                }
                .padding(10)
                Spacer()
                VStack(alignment: .center) {
                    Text(route.distance())
                        .foregroundStyle(.black)
                    Text("Distance")
                        .foregroundStyle(.black)
                }
                .padding(10)
                Spacer()
                VStack(alignment: .center) {
                    Text(route.calculateExcessTime())
                        .foregroundStyle(.black)
                    Text("Excess Time")
                        .foregroundStyle(.black)
                }
                .padding(10)
            }
            HStack {
                Button {
                    tracker.decrementRouteSelection()
                } label: {
                    Text("Previous Route")
                }
                Button {
                    tracker.incrementRouteSelection()
                } label: {
                    Text("Next Route")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .shadow(radius: 4)
    }
}
