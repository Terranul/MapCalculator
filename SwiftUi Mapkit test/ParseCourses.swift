//
//  ParseCourses.swift
//  SwiftUi Mapkit test
//
//  Created by Ben Faraone on 2025-12-21.
//

import CoreXLSX
import Foundation
import CoreLocation

struct Course {
    var description: String
    var days: [String] // values of type ["Mon", "Wed"]
    var format: String // discussion, lecture, lab, tutorial...
    var startTime: String
    var endTime: String
    var location: String // the four letter building code (like ICCS)
    var semCode: String // value of either "Sem 1" or "Sem 2"
    
    init() {
        self.description = ""
        self.days = []
        self.format = ""
        self.startTime = ""
        self.endTime = ""
        self.location = ""
        self.semCode = ""
    }
    
}

class ParseCourses {
    
    func mapData(result: Result<URL, any Error>) -> [Course] {
        print("entered map data")
        
        var mapping: [Course] = []
        
        do {
            let data: URL = try extractData(result: result)
            defer {data.stopAccessingSecurityScopedResource()}
            let file = XLSXFile(filepath: data.path)
            
            guard let file else {
                fatalError("Bitch")
            }
        
            let workbooks = try file.parseWorkbooks()
            // we just want the first workbook
            let inititalWorksheet : [(String?, String)] = try file.parseWorksheetPathsAndNames(workbook: workbooks.first!)
            print("passed initial worksheet")
            let worksheet : (name: String?, path: String) = inititalWorksheet.first!
            print("passed worksheet")
            let curWorksheet = try file.parseWorksheet(at: worksheet.path)
            print("passed curWorksheet")
            
            // the first row are the titles, so we don't need those
            let rows = curWorksheet.data?.rows.dropFirst() ?? []
            
            for row in rows {
                mapping.append(generateCourse(row: row))
            }
        } catch let e as CoreXLSXError {
            switch e {
            case .archiveEntryNotFound:
                print("Missing a required part of the XLSX file")
            case .invalidCellReference:
                print("invalidCellReference")
            case .dataIsNotAnArchive:
                print("data is not an archive ref")
            case .unsupportedWorksheetPath:
                print("If this error is thrown it is time to go fuck myself")
            }
        }
            catch {
                print("some other error")
            }
            return mapping
    }
        
    func extractData(result: Result<URL, any Error>) throws-> URL {
        // the interface allows the user to select multiple files, so we get a list of URL
        // for my case, the user is limited to one file, so there will only ever be one entry
        switch result {
        case Result.success(let data):
            print(data.lastPathComponent)
            // we need this for permission to use the user file
            guard data.startAccessingSecurityScopedResource() else {
                // if false
                throw FileError()
            }
            print("passed extract data")
            return data
        case Result.failure(_):
            throw FileError()
        }
    }
    
    private func generateCourse(row: Row) -> Course {
        var course: Course = Course()
        let cells = row.cells
        for i in 0..<cells.count {
            guard let text = cells[i].inlineString?.text else {
                continue
            }
            switch i {
            case 0:
                parseDescription(listing: text, course: &course)
                print("description result: \(course.description)")
            case 2:
                course.format = text
                print("format result: \(course.format)")
            case 4:
                parseDate(date: text, course: &course)
                print("---------------------------------------")
            default:
                continue
            }
        }
        return course
    }
    
    private func parseDescription(listing: String, course: inout Course) {
        // format "CPSC_V 304 - Introduction to Relational Databases"
        let substring = listing[listing.startIndex..<listing.index(listing.startIndex, offsetBy: 10)]
        course.description = String(substring)
    }
    
    private func parseDate(date: String, course: inout Course) {
        var result = date
        parseSemester(days: date, course: &course)
        print("Semester code result: \(course.semCode)")
        result = String(result.dropFirst(25))
        result = extractMeetingDays(days: result, course: &course)
        print("Meeting Days result: \(course.days)")
        result = parseTimes(days: result, course: &course)
        print("Event times result: \(course.startTime) to \(course.endTime)")
        parseLocation(days: result, course: &course)
        print("Location result: \(course.location)")
        
    }
    
    private func extractMeetingDays(days: String, course: inout Course) -> String {
        // in form " Tue Thu "
        var list: [String] = []
        var currentDay: String = ""
        var count: Int = 0
        for char in days {
            if char == Character(" ") {
                if (currentDay != "") {
                    list.append(currentDay)
                }
                currentDay = ""
            } else if (char == Character("|")) {
                let half = currentDay.dropLast()
                currentDay = String(half)
                count += 1
                break
            } else {
                currentDay.append(char)
            }
            count += 1
        }
        course.days = list
        var result: String = days
        result = String(result.dropFirst(count))
        return result
    }
    
    private func parseTimes(days: String, course: inout Course) -> String {
        // in form " 12:30 p.m. - 2:00 p.m. "
        var result = parseTime(days: days) { cur in
            course.startTime = cur
        }
        result = parseTime(days: result) { cur in
            course.endTime = cur
        }
        return result
    }
    
    private func parseTime(days: String, onTermination: (String) -> Void) -> String {
        var data = days
        data = String(data.dropFirst())
        var count = 0
        var cur = ""
        for char in data {
            if (char == Character("-") || char == Character("|")) {
                count += 1
                data = String(data.dropFirst(count))
                cur = String(cur.dropLast())
                onTermination(cur)
                return data
            } else {
                cur.append(char)
                count += 1
            }
        }
        return "Invalid result"
    }
    
    private func parseLocation(days: String, course: inout Course) {
        var count = 0
        var cur = ""
        var data = days
        data = String(data.dropFirst(6))
        for char in data {
            if char == Character("(") {
                count += 1
                data = String(data.dropFirst(count))
                break
            }
            count += 1
        }
        count = 0
        for char in data {
            if char == Character(")") {
                course.location = cur
                return
            } else {
                cur.append(char)
            }
        }
    }
    
    private func parseSemester(days: String, course: inout Course) {
        // always going to be in a format of equal length and disposition to '2025-09-04 - 2025-12-04' (23 char)
        // to determine sem 1 or sem 2, we will compare the starting date with a reference date
        let date = days[days.startIndex..<days.index(days.startIndex, offsetBy: 10)]
        let formatter = FormatTime()
        let semCode = formatter.determineSemester(value: String(date))
        course.semCode = semCode
    }
    
    @MainActor
    func formatDataSelection(result: Result<URL, any Error>) {
        let tracker = DayTracker.getInstance(selectedDay: "Mon", selectedSemester: "Sem1")
        // reset all data in the tracker for now
        tracker.resetData()
        print("Entered data selection")
        // this function is the bridge between the course format in this class, and the location format in the dayTracker
        let courses = mapData(result: result)
        let decoder = JSONController()
        let mapping = decoder.returnJSONMapping()
        let formatter = FormatTime()
        let curDaySelection = tracker.getDaySelection()
        let curSemSelection = tracker.getSelectedSemester()
        for course in courses {
            // it may be easier to build the day:location dictionary here, but it is better to use the functions in the tracker so
            // previous data is preserved and we don't mess up the trackers internal select values
            guard let coordinate = convertLocationCode(code: course.location, mapping: mapping) else {
                continue
            }
            let startTime = formatter.convertTo24HR(time: course.startTime)
            let endTime = formatter.convertTo24HR(time: course.endTime)
            let location = Location(coord: coordinate, arrivalTime: startTime, exitTime: endTime, label: "\(course.description) \(course.format)")
            // we want to keep track of the selection the tracker had before so we can put everything back the way it was after we inject data
            course.semCode == "Sem 1" ? tracker.swapSelection(value: "Sem 1") : tracker.swapSelection(value: "Sem 2")
            for day in course.days {
                tracker.swapSelection(value: day)
                tracker.addData(value: location)
            }
        }
        tracker.swapSelection(value: curDaySelection)
        tracker.swapSelection(value: curSemSelection)
        // the view should activate the task for these so it we don't need to generate the routes here
    }
    
    private func convertLocationCode(code: String, mapping: [String: MapLoc]) -> CLLocationCoordinate2D? {
        if let loc = mapping[code] {
            let coord = CLLocationCoordinate2D(latitude: Double(loc.latitude), longitude: Double(loc.longitude))
            return coord
        } else {
            // entry not in current data. In the future we may add an ability for the user to submit the location
            // for now we will omit
            print("Unable to find location data for bulding \(code), omitting")
            return nil
        }
    }
    
    
}
