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
    @State var semSelection: Int = 0
    @Binding var showTextField: Bool
    private let items: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let semesters: [String] = ["Sem 1", "Sem 2"]
    
    var body: some View {
        VStack {
            Image(.sidebar)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .frame(width: 50, height: 50)
                )
                .onTapGesture {
                    withAnimation {
                        if !showTextField {
                            isVisisble.toggle()
                        } else {
                            if (!isVisisble) {
                                isVisisble.toggle()
                            }
                        }
                    }
                }
                .padding(.init(top: 15, leading: 20, bottom: 20, trailing: 20))
            if isVisisble && !showTextField{
                VerticalPicker(items: items, selectHeight: 55, frameWidth: 55, selection: $selection) { item in
                    Text(item)
                        .foregroundStyle(item == items[selection] ? .white : .black)
                        .padding(5)
                }
                .transition(.move(edge: .leading))
                
                .padding(.bottom, 10)
                // the picker is general and will always call swapSelection in tracker put luckily the function will diffrentiate between Day inputs
                VerticalPicker(items: semesters, selectHeight: 55, frameWidth: 55, selection: $semSelection) { item in
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

