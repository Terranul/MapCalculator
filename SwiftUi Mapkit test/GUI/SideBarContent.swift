//
//  SideBarContent.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-03.
//

import SwiftUI

struct SideBarContent: View {
    
    @State public var isVisible: Bool = true
    
    var body: some View {
        SideBar(isVisible: $isVisible) {
            CollapsedView()
        } outerContent: {
            OuterContent()
        }
        .background(
            Rectangle()
                .fill(.white)
        )
    }
}

struct CollapsedView: View {
    
    var body: some View {
        Image(.send)
    }
}

struct OuterContent: View {
    
    var body: some View {
        Text("test")
    }
}
