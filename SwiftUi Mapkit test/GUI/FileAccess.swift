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
            
        }
        .fileImporter(isPresented: $isDisplayed, allowedContentTypes: [.spreadsheet]) {result in 
            
//            switch result {
//            case Result.success(let data):
//                let url: URL = data
//            case Result.failure(let error):
                
            }
        }

}
