//
//  ContentView.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2025-12-21.
//

import SwiftUI

struct ContentView: View {
    
    let parses: ParseCourses = ParseCourses()
    
    var body: some View {
        NavigationStack {
            ConvertTouchToPoint()
        }
    }
}

#Preview {
    ContentView()
}
