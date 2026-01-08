//
//  FileAccess.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-06.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct FileAccess: View {
    
    // allows users to submit files to the app
    // files are to be parsed and sent to the tracker hopefully
    @State public var isDisplayed: Bool = true
    private let parser: ParseCourses = ParseCourses()
    
    var body: some View {
        VStack {
            Text("This view should help print the file contents")
        }
        .fileImporter(isPresented: $isDisplayed, allowedContentTypes: [.spreadsheet]) { result in
            let value = parser.mapData(result: result)
        }
    }

}
