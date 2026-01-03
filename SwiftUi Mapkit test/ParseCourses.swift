//
//  ParseCourses.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2025-12-21.
//

import CoreXLSX
import Foundation

class ParseCourses {
    
    let filepath: String = "/Users/benfaraone/Downloads/Current_Classes.xlsx"
    
    func mapData() -> [String : String] {
        print("entering function")
        var mapping: [String : String] = [:]
        
        let exists = FileManager.default.fileExists(atPath: filepath)
        print("Exists:", exists)
        
        guard let file = XLSXFile(filepath: filepath) else {
            fatalError("XLSX file at \(filepath) is corrupted or does not exist")
        }
    
        
        do {
            // appararently we need this for some reason I don't understand
            let sharedString: SharedStrings? = try file.parseSharedStrings()
            
            var workbooks = try file.parseWorkbooks()
            // we just want the first workbook
            let inititalWorksheet : [(String?, String)] = try file.parseWorksheetPathsAndNames(workbook: workbooks.first!)
            print("passed initial worksheet")
            let worksheet : (name: String?, path: String) = inititalWorksheet.first!
            print("passed worksheet")
            let curWorksheet = try file.parseWorksheet(at: worksheet.path)
            print("passed curWorksheet")
            
            for row in curWorksheet.data?.rows ?? [] {
                // we need to populate the current mapping
                // format for each cell per row:
                // course section format delivery meeting instructor
                // course will be the key, and meeting will be the value (corresponding to index 0 and 4)
                let data = row.cells
                for cell in data {
                    print(cell.stringValue(sharedString!)!)
                }
            }
        } catch {
            fatalError("Error thrown bitch")
        }
        return mapping
    }
    
}
