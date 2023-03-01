//
//  AilmentSector.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

/// Defines a Ailment Sector which will end up in the report as HTML.
public struct AilmentSector {

    /// The title of the `Ailment` report which will also be used as HTML anchor.
    public let title: String

    /// The `Ailment` to show in the chapter.
    public internal(set) var diagnostics: Ailment

    /// Whether the title should be visibly shown.
    public let shouldShowTitle: Bool

    /// An optional HTML formatter to customize the HTML format. `diagnostics.html()` will be used if this formatter is set to `nil`,
    public let formatter: HTMLFormatting.Type?

    public init(title: String,
                diagnostics: Ailment,
                shouldShowTitle: Bool = true,
                formatter: HTMLFormatting.Type? = nil) {
        self.title = title
        self.diagnostics = diagnostics
        self.shouldShowTitle = shouldShowTitle
        self.formatter = formatter
    }
}

extension AilmentSector {
    mutating func applyingFilters(_ filters: [AilmentFilter.Type]) {
        filters.forEach { reportFilter in
            diagnostics = reportFilter.filter(diagnostics)
        }
    }

    public func html() -> HTML {
        var html = "<div class=\"chapter\">"
        html += "<span class=\"anchor\" id=\"\(title.anchor)\"></span>"

        if shouldShowTitle {
            html += "<h3>\(title)</h3>"
        }

        html += "<div class=\"chapter-content\">"

        if let formatter = formatter {
            html += formatter.format(diagnostics)
        } else {
            html += diagnostics.html()
        }

        html += "</div></div>"
        return html
    }
}
