//
//  RestaurantTimingsViewModel.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import Foundation
import  SwiftUI

class RestaurantTimingsViewModel: ObservableObject {
    
    let useCase: LocationUsecase
    @Published var resultState: ResultState<LocationData> = .initalState
    @Published var locationdata: LocationData = LocationData(locationName: "", hours: [])
    @Published var displayText: String = ""
    @Published var allTimings  = [DayTimings]()
    @Published var restaurantStatusColor  = Color.green
    @Published var groupedByWeekDay = [String: [DayAndTimings]]()

    // custom initialization
    init(locationRepo: LocationRepositoryProtocol = LocationRepository()) {
        self.useCase = LocationUsecase(locationRepository: locationRepo)
    }
    
    func fetchRestaurantData() {
        resultState = .loading
        useCase.fetchLocationData { [weak self] result in
            switch result {
            case .success(let response):
                self?.locationdata = response
                self?.resultState = .fetchedResult(response: response)
                _ = self?.formatHours(response.hours)
                self?.updateUI()
            case .failure(let error):
                self?.resultState = .failedToLoad(message: error?.errorDescription ?? "")
            }
        }
    }
    
    func convertTime24To12(_ time: String) -> String {
        if time == "24:00:00" {
            return "12am"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        if let date = dateFormatter.date(from: time) {
            dateFormatter.dateFormat = "ha"
            return dateFormatter.string(from: date).lowercased()
        }
        return time
    }

    func formatHours(_ hours: [DayAndTimings]) -> [String: String] {
        var hoursDict = [String: [String]]()
        var groupedByWeek = [String: [DayAndTimings]]()
        for hour in hours {
            let day = hour.dayOfWeek
            if groupedByWeek[day] != nil {
                groupedByWeek[day]?.append(hour)
            } else {
                groupedByWeek[day] = [hour]
            }
        }
        for (day, _ ) in groupedByWeek {
            groupedByWeek = updateTimings(day: day, values: groupedByWeek)
        }
        groupedByWeekDay = groupedByWeek
        // Converting time slots to 12 hourd format
        for (day, _ ) in groupedByWeek {
            let day = day
            for hour in groupedByWeek[day] ?? [] {
                let startTime = convertTime24To12(hour.startLocalTime)
                let endTime = convertTime24To12(hour.endLocalTime)
                let timeRange = "\(startTime)-\(endTime)"
                
                if hoursDict[day] != nil {
                    hoursDict[day]?.append(timeRange)
                } else {
                    hoursDict[day] = [timeRange]
                }
            }
        }
    
        allTimings.removeAll()

        
        var formattedHours = [String: String]()
        for (day, times) in hoursDict {
            let timesString = times.joined(separator: ", ")
            if timesString == "12am-12am" {
                formattedHours[day] = "Open 24 hours"
            } else {
                formattedHours[day] = timesString
            }
        }
        _ = formattedHours.keys.map { key in
            allTimings.append((DayTimings(dayOfWeek: key, time: formattedHours[key]?.components(separatedBy: ", ") ?? [])))
        }
        allTimings = allTimings.sorted(by: { $0.weekDay < $1.weekDay })
        
        return formattedHours
    }
    
    func sortedOpeningHours() -> [DayTimings] {
        let currentIndex = Date().weekday-1
        var temp = allTimings.sorted(by: { $0.weekDay < $1.weekDay })
        let sortedHours = Array(allTimings[currentIndex...]) + Array(allTimings[..<currentIndex])
        return sortedHours
    }
    
    func getNextDay(_ day: String) -> String {
        switch day {
        case "MON": return "TUE"
        case "TUE": return "WED"
        case "WED": return "THU"
        case "THU": return "FRI"
        case "FRI": return "SAT"
        case "SAT": return "SUN"
        case "SUN": return "MON"
        default: return day
        }
    }

    func getPreviousDay(_ day: String) -> String {
        switch day {
        case "MON": return "SUN"
        case "TUE": return "MON"
        case "WED": return "TUE"
        case "THU": return "WED"
        case "FRI": return "THU"
        case "SAT": return "FRI"
        case "SUN": return "SAT"
        default: return day
        }
    }

    func updateUI() {
        let currentDate = Date()
        switch EnumDays(rawValue: currentDate.weekday) {
        case .some(.SUNDAY):
            updateStatusAndText(day: .SUNDAY)
        case .some(.MONDAY):
            updateStatusAndText(day: .MONDAY)
        case .some(.TUESDAY):
            updateStatusAndText(day: .TUESDAY)
        case .some(.WEDNESDAY):
            updateStatusAndText(day: .WEDNESDAY)
        case .some(.THURSDAY):
            updateStatusAndText(day: .THURSDAY)
        case .some(.FRIDAY):
            updateStatusAndText(day: .FRIDAY)
        case .some(.SATURDAY):
            updateStatusAndText(day: .SATURDAY)
        case .none:
            restaurantStatusColor = .red
            displayText = "Closed"
            break
        }
        
    }
    func updateStatusAndText(day: EnumDays) {
        let dates = groupedByWeekDay[day.shortName]
        if isDateInDatesRange(dates: dates ?? []).0 {
            restaurantStatusColor = .green
            if isDateInDatesRange(dates: dates ?? []).1 {
                restaurantStatusColor = .yellow
            }
        }  else {
            restaurantStatusColor = .red
            getdisplyText(day: day)
        }
    }
    func getdisplyText(day: EnumDays) {
            if let dates: [DayAndTimings] =  groupedByWeekDay[day.shortName] {
                if dates.isEmpty {
                    self.getdisplyText(day: day.nextDay)
                } else {
                    let hour: Int = Date().calendar.component(.hour, from: Date().currentdate)
                    let closestFutureStartDates = dates.filter({ Int($0.startLocalTime.components(separatedBy: ":")[0]) ?? 0 > hour })
                    if day.shortName.getDayOfWeekIndex() == Date().weekday {
                        // Find the closest future start date
                        if let closestFutureStartDate = closestFutureStartDates.sorted(by: { $0.startLocalTime < $1.startLocalTime
                        }).first {
                            displayText = "Opens again at \(reformat(string: (convertTime24To12(closestFutureStartDate.startLocalTime)))) "
                        } else {
                            getdisplyText(day: day.nextDay)
                        }
                    } else {
                        displayText = "Opens \(day.description) \(reformat(string: (convertTime24To12(dates[0].startLocalTime)))) "
                    }
                }
            } else {
                getdisplyText(day: day.nextDay)
            }
    }
    func reformat(string: String) -> String {
        if string.lowercased() == "12am" {
            return "Midnight"
        } else {
            return string
        }
    }
    func isDateInDatesRange(dates: [DayAndTimings]) -> (Bool, Bool) {
        guard !dates.isEmpty else {
            return (false, false)
        }
        // Date formatter to convert string to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let currentDate = Date()
        let calendar = Calendar.current
        // Define the desired components
        let desiredComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let todayComponents = calendar.dateComponents(desiredComponents, from: currentDate)
    
        for (index, timing) in dates.enumerated() {
            // Create a specific date
            var dateComponents = DateComponents()
            dateComponents.year = todayComponents.year
            dateComponents.month = todayComponents.month
            dateComponents.day = todayComponents.day
            dateComponents.hour = Int(timing.startLocalTime.components(separatedBy: ":")[0])
            dateComponents.minute = Int(timing.startLocalTime.components(separatedBy: ":")[1])
            dateComponents.second = Int(timing.startLocalTime.components(separatedBy: ":")[2])
            
            let startDate = calendar.date(from: dateComponents)
            let endHour = Int(timing.endLocalTime.components(separatedBy: ":")[0]) ?? 0
            let startHour = Int(timing.startLocalTime.components(separatedBy: ":")[0]) ?? 0
            
            if endHour < startHour {
                let nextDayComponents = calendar.dateComponents(desiredComponents, from: startDate?.getTomorrow() ??  Date())
                dateComponents.year = nextDayComponents.year
                dateComponents.month = nextDayComponents.month
                dateComponents.day = nextDayComponents.day
            }
            
            dateComponents.hour = Int(timing.endLocalTime.components(separatedBy: ":")[0])
            dateComponents.minute = Int(timing.endLocalTime.components(separatedBy: ":")[1])
            dateComponents.second = Int(timing.endLocalTime.components(separatedBy: ":")[2])
            
            let endDate = calendar.date(from: dateComponents)
            
            if let start = startDate,
               let end = endDate {
                let diffcomponents = calendar.dateComponents([.minute], from: currentDate, to: end)
                if currentDate  >= start && currentDate <= end {
                    if index == dates.count-1 {
                        displayText = "Open untill \(reformat(string: convertTime24To12(timing.endLocalTime)))"
                    } else {
                        displayText = "Open untill \(reformat(string: convertTime24To12(dates[index].endLocalTime))), reopens at \(convertTime24To12(dates[index+1].startLocalTime)) "
                    }
                    return (currentDate  >= start && currentDate <= end, (diffcomponents.minute ?? 0 < 60) )
                }
            }
        }
        return (false, false)
    }

    func updateTimings(day: String, values: [String: [DayAndTimings]])  -> [String: [DayAndTimings]]{
        var result = [String: [DayAndTimings]]()
        result = values
        if let timings = result[day], !timings.isEmpty {
            var tempTimings = timings
            if let nextDaytimings = result[getNextDay(day)], !nextDaytimings.isEmpty {
                var tempNextDayTimings = nextDaytimings
                if tempTimings.contains(where: { $0.endLocalTime == AppConstants.StringConstants.dayEndTime  }) {
                    if nextDaytimings.contains(where: { ($0.startLocalTime == AppConstants.StringConstants.dayStartTime) && (($0.endLocalTime != AppConstants.StringConstants.dayEndTime)) }) {
                        let midnight = tempNextDayTimings.first(where: { $0.startLocalTime == AppConstants.StringConstants.dayStartTime  })
                        if var temp = tempTimings.first(where: { $0.endLocalTime == AppConstants.StringConstants.dayEndTime }) {
                            temp.updateEndLocalTime(midnight?.endLocalTime ?? AppConstants.StringConstants.dayEndTime)
                            tempNextDayTimings.removeAll(where: { $0.startLocalTime == AppConstants.StringConstants.dayStartTime  })
                            tempTimings.removeAll(where: { $0.startLocalTime == temp.startLocalTime  })
                            tempTimings.append(temp)
                            result[day] = tempTimings
                            result[getNextDay(day)] = tempNextDayTimings
                        }
                    }
                }
            }
            if let prevDaytimings = result[getPreviousDay(day)], !prevDaytimings.isEmpty {
                var tempPrevDayTimings = prevDaytimings
                if tempPrevDayTimings.contains(where: { ($0.endLocalTime == AppConstants.StringConstants.dayEndTime) && ($0.startLocalTime != AppConstants.StringConstants.dayStartTime)  }) {
                    if tempTimings.contains(where: { $0.startLocalTime == AppConstants.StringConstants.dayStartTime  }) {
                        let midnight = tempTimings.first(where: { $0.startLocalTime == AppConstants.StringConstants.dayStartTime })
                        if var temp = prevDaytimings.first(where: { $0.endLocalTime == AppConstants.StringConstants.dayEndTime }) {
                            temp.updateEndLocalTime(midnight?.endLocalTime ?? AppConstants.StringConstants.dayEndTime)
                            tempTimings.removeAll(where: { $0.startLocalTime == AppConstants.StringConstants.dayStartTime })
                            result[day] = tempTimings
                            tempPrevDayTimings.removeAll(where: { $0.endLocalTime == AppConstants.StringConstants.dayStartTime })
                            var copy: [DayAndTimings] = tempPrevDayTimings
                            copy.append(temp)
                            result[getPreviousDay(day)] = copy
                        }
                    }
                }
            }
        }
        return result
    }
}

extension String {
    func getDayOfWeekIndex() -> Int {
        switch self {
        case "SUN": return 1
        case "MON": return 2
        case "TUE": return 3
        case "WED": return 4
        case "THU": return 5
        case "FRI": return 6
        case "SAT": return 7
        default: return -1
        }
    }
}

extension Date {
    var currentdate: Date { Date() }
    var calendar: Calendar { Calendar.current }
    var weekday: Int {
        (calendar.component(.weekday, from: self) - calendar.firstWeekday + 7) % 7 + 1
    }

    func getLast6Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)
    }
    
    func getLast3Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)
    }
    
    func getYesterday() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func getTomorrow() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    func getOvermorrow() -> Date? {
        return Calendar.current.date(byAdding: .day, value: 2, to: self)
    }
    
    func getLast7Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)
    }
    
    func getLast30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -30, to: self)
    }
}

// MARK: - Assumptioms
/**
    * porttrait only
    * from ios 15  above
 1) no overlappings like 09:00:00 -- 12:00:00, 10:00:00--11:00:00
 2) Not works for all splisfor dat like 1hour with zero delay like 09:00:00--10:00:00, 10:00:00--11:00:00, , 11:00:00--12:00:00,
 3) not works for minutes assumed minutes always 00
 4) assumed must one future day  timeslot
 5) Always slot will be 00:00:00 to 24:00:00 no other numbers
 */
