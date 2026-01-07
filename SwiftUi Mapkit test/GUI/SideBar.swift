//
//  SideBar.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-03.
//

import SwiftUI

struct SelectablePicker: View {
    
    @State public var isVisisble: Bool = false
    @State var selection: Int = 0
    private let items: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack {
            Text("More")
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                )
                .onTapGesture {
                    withAnimation {
                        isVisisble.toggle()
                    }
                }
                .padding(5)
            if isVisisble {
                VerticalPicker(items: items, selectHeight: 40, frameWidth: 40, selection: $selection) { item in
                    Text(item)
                        .foregroundStyle(item == items[selection] ? .white : .black)
                        .padding(5)
                }
                .transition(.move(edge: .leading))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct VerticalPicker<Item: Hashable, Content: View>: View {
    
    var items: [Item]
    public var selectHeight: Int
    public var frameWidth: Int
    // selection values from 0 to items.count - 1
    @Binding var selection: Int
    public var label: (Item) -> Content
    @Namespace private var ns
    
    @EnvironmentObject public var tracker: DayTracker
    
    var body: some View {
        VStack {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let isSelection: Bool = index == selection
                ZStack {
                    if isSelection {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray)
                            .matchedGeometryEffect(id: "animation", in: ns)
                            .frame(width: CGFloat(frameWidth), height: CGFloat(selectHeight))
                    }
                    label(item)
                        .padding(5)
                }
                .onTapGesture {
                    withAnimation {
                        selection = index
                    }
                    tracker.swapSelection(value: item as! String)
                }
            }
        }
        .background (
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: CGFloat(frameWidth))
        )
        .padding(10)
    }
}

