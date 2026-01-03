//
//  FormateTime.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2025-12-22.
//

import Foundation

struct FormatTime {
    
    
    // time is to be in HH:MM format (24 hour clock)
    // all times will be converted to the same day so it is possible to compare days
    func convert(time: String) -> Date{
        let prefix = "2002-09-11T"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = formatter.date(from: prefix + time)!
        print(date.description)
        return date
        
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
            let loc1Date = convert(time: loc1.label)
            let loc2Date = convert(time: loc2.label)
            return loc1Date < loc2Date
        }
    }
}
