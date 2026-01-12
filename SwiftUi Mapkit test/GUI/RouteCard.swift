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
            Text("\(route.source.exitTime) - \(route.destination.arrivalTime ?? route.destination.exitTime)")
                .font(.headline)
                .foregroundStyle(.black)
            HStack {
                Text(route.source.label)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text("TO")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .padding(2)
                Spacer()
                Text(route.destination.label)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
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
