//
//  VeticalPicker.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-04.
//

import SwiftUI


struct VerticalPicker<Item: Hashable, Content: View>: View {
    
    var items: [Item]
    public var selectHeight: Int
    public var frameWidth: Int
    // selection values from 0 to items.count - 1
    @Binding var selection: Int
    public var label: (Item) -> Content
    @Namespace private var ns
    
    var body: some View {
        VStack {
            ForEach(items.indices, id: \.self) { index in
               let item = items[index]
                let isSelection: Bool = index == selection
                ZStack {
                    if isSelection {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray)
                            .animation(.spring(), value: selection)
                            .frame(width: CGFloat(frameWidth), height: CGFloat(selectHeight))
                    }
                    label(item)
                        .padding(5)
                }
                .onTapGesture {
                    withAnimation {
                        selection = index
                    }
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
