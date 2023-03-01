//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

extension DateFormatter {
    static let current: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "GMT")!
        return formatter
    }()
}
