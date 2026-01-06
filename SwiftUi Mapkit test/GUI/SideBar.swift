//
//  SideBar.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-03.
//

import SwiftUI

struct SideBar<InnerContent: View, OuterContent: View>: View {

    @Binding var isVisible: Bool
    let innerContent: () -> InnerContent
    let outerContent: () -> OuterContent

    var body: some View {
        VStack(alignment: .leading) {

            outerContent()
                .onTapGesture {
                    withAnimation(.spring()) {
                        isVisible.toggle()
                    }
                }
                .padding(10)

            if isVisible {
                innerContent()
                    .transition(.move(edge: .leading))
            }
        }
    }
}
