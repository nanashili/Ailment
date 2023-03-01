//
//  GeneralReporter.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

/// Prints generic information in a separated chapter. Can be subclassed to change the default copy.
open class GeneralReporter: AilmentReporting {

    /// The title shown as introduction for the Ailment Report. Can be overwritten for a custom title. Defaults to "Information".
    open var title: String {
        return "Information"
    }

    /// The description shown as introduction for the Ailment Report. Can be overwritten for a custom description.
    open var description: HTML {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from: Date())

        return """
        <p>This diagnostics report can help our Support team to solve the issues you're experiencing. It includes information about your device, settings, logs, and specific user data that allows our engineers to find out what's going on.</p>
        <p>This report was generated on <i>\(dateString) GMT+0</i></p>
        """
    }

    public func report() -> AilmentSector {
        return AilmentSector(title: title, diagnostics: description, shouldShowTitle: false)
    }
}
