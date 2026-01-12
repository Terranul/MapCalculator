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
    // lets store the partition here too becuase why not
    static var partitionDate: Date? = nil
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
        return locations.sorted { (loc1: Location, loc2: Location) in
            let loc1Date: Date = convert(time: loc1.exitTime)
            let loc2Date: Date = convert(time: loc2.exitTime)
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
        if let date = date {
            let outputFormatter = DateFormatter.cachedDate
                outputFormatter.locale = Locale(identifier: "en_US_POSIX")
                outputFormatter.dateFormat = "HH:mm"

                return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func determineSemester(value: String) -> String {
        // if value is after Dec 28 but before
        let formatter = DateFormatter.cachedDate
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: value) else {
            print("Badly formatted date of \(value). Defaults to Sem 1")
            return "Sem 1"
        }
        if let partition = DateFormatter.partitionDate  {
            if isSemesterOne(partition: partition, date: date) {
                return "Sem 1"
            } else {
                return "Sem 2"
            }
        } else {
            let year = value[value.startIndex..<value.index(value.startIndex, offsetBy: 4)]
            guard year.count == 4 else {
                print("Year is badly formatted for date \(value) with year \(year). Defaults to semester 1")
                return "Sem 1"
            }
            // may be slighly less code to use may 1st as the partition but easier to follow using january
            DateFormatter.partitionDate = returnRefDate(value: Int(String(year))!, date: date)
            if isSemesterOne(partition: DateFormatter.partitionDate!, date: date) {
                return "Sem 1"
            } else {
                return "Sem 2"
            }
        }
    }
    
    private func isSemesterOne(partition: Date, date: Date) -> Bool{
        return date < partition
    }
    
    // string is the year value (YYYY) and date is the actual converted date
    private func returnRefDate(value: Int, date: Date) -> Date {
        // I must admit I spent lots of time trying to figure out the partition date, but here is the goal
        // - Take the value and set the month to May
        // - if the value has past this date, then we know our partition must be at Jan 1 of the next year
        // - otherwise it is set to january 1 of the current year
        let calendar: Calendar = Calendar.current
        let determinant = calendar.date(from: DateComponents(year: value, month: 5, day: 1))
        if date > determinant! {
            return calendar.date(from: DateComponents(year: value + 1, month: 1, day: 1))!
        } else {
            return calendar.date(from: DateComponents(year: value, month: 1, day: 1))!
        }
    }
}
