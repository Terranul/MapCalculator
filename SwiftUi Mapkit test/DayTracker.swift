//
//  DayTracker.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2026-01-05.
//

import SwiftUI
internal import Combine


class DayTracker: ObservableObject {
    
    // the dayTracker and FormatTime should realisticly be combined, but this class was a late addition
    
    @Published private(set) var currentSelection: [Location] = []
    private var internalSelect: String
    private var data: [String : [Location]] = [ : ]
    
    init(internalSelect: String) {
        self.internalSelect = internalSelect
    }
    
    func addData(value: Location) {
        var curValue: [Location] = data[internalSelect, default: []]
        curValue.append(value)
        // reorder after every addition
        let formatter = FormatTime()
        let orderedSelection = formatter.convertLocations(locations: curValue)
        data[internalSelect] = orderedSelection
        currentSelection = orderedSelection
    }
    
    func isValidTime(value: String) -> Bool{
        let formatter = FormatTime()
        return formatter.isValidTime(time: value)
    }
    
    func swapSelection(value: String) {
        currentSelection = data[internalSelect, default: []]
    }
    
    func getData() -> [Location] {
        return data[internalSelect, default: []]
    }
    
    func getSelection() -> String {
        return internalSelect
    }
}
