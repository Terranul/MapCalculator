//
//  FormateTime.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2025-12-22.
//

import Foundation

extension DateFormatter {
    // the formatter is still expensive...
    static let cachedDate = DateFormatter()
}

struct FormatTime {
    
    
    // time is to be in HH:MM format (24 hour clock)
    // all times will be converted to the same day so it is possible to compare days
    func convert(time: String) -> Date{
        let prefix = "2002-09-11T"
        let formatter = returnPreferredFormatter()
        let date = formatter.date(from: prefix + time)!
        //print(date.description)
        return date
        
    }
    
    func returnPreferredFormatter() -> DateFormatter {
        let formatter = DateFormatter.cachedDate
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
    
    func sortByTime(times: [Date]) -> [Date]{
        return times.sorted { date1, date2 in
                return date1 < date2
        }
    }
    
    func convertAndSortByTime(times: [String]) -> [Date] {
        var dateArray: [Date]  = []
        for date in times {
            dateArray.append(convert(time: date))
        }
        return sortByTime(times: dateArray)
    }
    
    func convertLocations(locations: [Location]) -> [Location] {
        return locations.sorted { loc1, loc2 in
            let loc1Date = convert(time: loc1.time)
            let loc2Date = convert(time: loc2.time)
            return loc1Date < loc2Date
        }
    }
    
    // should be storing time as a date, and this function would not be needed, but who cares
    func isValidTime(time: String) -> Bool {
        let prefix = "2002-09-11T"
        let formatter = returnPreferredFormatter()
        let date = formatter.date(from: prefix + time)
        if date != nil {
            return true
        } else {
            return false
        }
    }
    
    // expected for inputs like HH:MM p.m./a.m.
    func convertTo24HR(time: String) -> String {
        var timeRep = time
        timeRep = timeRep.replacingOccurrences(of: "p.m.", with: "PM")
        timeRep = timeRep.replacingOccurrences(of: "a.m.", with: "AM")
        let formatter = DateFormatter.cachedDate
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        let date = formatter.date(from: timeRep)
        return date
    }
}
