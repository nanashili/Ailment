//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation
import CoreTelephony

#if os(iOS) && !targetEnvironment(macCatalyst)
/// Shows an insight on whether the user has enabled cellular data system-wide for this app.
struct CellularAllowedInsight: IInsightSection {

    let sectionName = "Cellular data allowed"
    let sectionResult: InsightResult

    init() {
        let cellularData = CTCellularData()
        switch cellularData.restrictedState {
        case .restricted:
            self.sectionResult = .error(message: "The user has disabled cellular data usage for this app.")
        case .notRestricted:
            self.sectionResult = .success(message: "Cellular data is enabled for this app.")
        default:
            self.sectionResult = .warn(message: "Unable to determine whether cellular data is allowed for this app.")
        }
    }
}
#endif
