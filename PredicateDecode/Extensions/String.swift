import Foundation

extension String {
    
    var asAppleArtistIdsArray: [String] {
        self
            .components(separatedBy: ValuesSeparator)
    }
    
    var asVocalLevelsArray: [VocalLevel] {
        self
            .components(separatedBy: ValuesSeparator)
            .compactMap {
                guard let rawValue = Int($0),
                      let vocalLevel = VocalLevel(rawValue: rawValue) else {
                    return nil
                }
                return vocalLevel
            }
    }
}

extension String {
    var dateFromRangeDateFormat: Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy_MM_dd"
        return df.date(from: self)
    }
}

extension String {
    var parsedDateRange: (Date?, Date?)? {
        let separator = "..."
        
        if self.hasPrefix(separator) {
            
            //...2023_01_25
            let dateString = self.replacingOccurrences(of: separator, with: "")
            guard let date = dateString.dateFromRangeDateFormat else {
                return nil
            }
            return (nil, date)
            
        } else if self.hasSuffix(separator) {
            
            //2000_12_10...
            let dateString = self.replacingOccurrences(of: separator, with: "")
            guard let date = dateString.dateFromRangeDateFormat else {
                return nil
            }
            return (date, nil)

        } else {
            
            //2000_12_10...2023_01_25
            let components = self.components(separatedBy: "...")
            guard components.count == 2,
                  let startDateString = components.first,
                  let endDateString = components.last,
                  let startDate = startDateString.dateFromRangeDateFormat,
                  let endDate = endDateString.dateFromRangeDateFormat
            else { return nil }
            return (startDate, endDate)
            
        }
    }
    
    var parsedIntRange: (Int?, Int?)? {
        let separator = "..."
        
        if self.hasPrefix(separator) {
            
            //...1200
            let intString = self.replacingOccurrences(of: separator, with: "")
            guard let int = Int(intString) else {
                return nil
            }
            return (nil, int)
            
        } else if self.hasSuffix(separator) {
            
            //1200...
            let intString = self.replacingOccurrences(of: separator, with: "")
            guard let int = Int(intString) else {
                return nil
            }
            return (int, nil)

        } else {
            
            //500...1200
            let components = self.components(separatedBy: "...")
            guard components.count == 2,
                  let startIntString = components.first,
                  let endIntString = components.last,
                  let startInt = Int(startIntString),
                  let endInt = Int(endIntString)
            else { return nil }
            return (startInt, endInt)
        }
    }
    
    var parsedDoubleRange: (Int?, Int?)? {
        //TODO: DO this
        nil
    }
}
