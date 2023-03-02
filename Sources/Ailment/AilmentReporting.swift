//
//  AilmentReporting.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

public protocol AilmentReporting {
    /// Creates the report chapter.
    func report() -> AilmentSector
}

public enum AilmentReporter {

    public enum DefaultReporter: CaseIterable {
        case generalInfo
        case appSystemMetadata
        case smartInsights
        case logs
        case userDefaults

        public var reporter: AilmentReporting {
            switch self {
            case .generalInfo:
                return GeneralReporter()
            case .appSystemMetadata:
                return AppMetadataReporter()
            case .smartInsights:
                return InsightsReporter()
            case .logs:
                return LogReport()
            case .userDefaults:
                return UserDefaultsReporter()
            }
        }

        public static var allReporters: [AilmentReporting] {
            allCases.map { $0.reporter }
        }
    }

    /// The title that is used in the header of the web page of the report.
    static var reportTitle: String = "\(Bundle.appName) - Ailment Report"

    /// Creates the report by making use of the given reporters.
    /// - Parameters:
    ///   - reporters: The reporters to use. Defaults to `DefaultReporter.allReporters`.
    ///   Use this parameter if you'd like to exclude certain reports.
    ///   - filters: The filters to use for the generated diagnostics. Should conform to the `AilmentFilter` protocol.
    ///   - smartInsightsProvider: Provide any smart insights for the given `AilmentSector`.
    public static func create(
        filename: String = "Ailment-Report.html",
        using reporters: [AilmentReporting] = DefaultReporter.allReporters,
        filters: [AilmentFilter.Type]? = nil,
        smartInsightsProvider: SmartInsightsProviding? = nil
    ) -> AilmentReport {
        /// We should be able to parse Smart insights out of other chapters.
        /// For example: read out errors from the log chapter and create insights out of it.
        ///
        /// Therefore, we are generating insights on the go and add them to the Smart Insights later.
        var smartInsights: [IInsightSection] = []

        var reportChapters = reporters
            .filter { ($0 is InsightsReporter) == false }
            .map { reporter -> AilmentSector in
                var chapter = reporter.report()
                if let filters = filters, !filters.isEmpty {
                    chapter.applyingFilters(filters)
                }
                if let smartInsightsProvider = smartInsightsProvider {
                    let insights = smartInsightsProvider.smartInsights(for: chapter)
                    smartInsights.append(contentsOf: insights)
                }

                return chapter
            }

        if let smartInsightsChapterIndex = reporters.firstIndex(where: { $0 is InsightsReporter }) {
            var smartInsightsReporter = InsightsReporter()
            smartInsightsReporter.insights.append(contentsOf: smartInsights)
            let smartInsightsChapter = smartInsightsReporter.report()
            reportChapters.insert(smartInsightsChapter, at: smartInsightsChapterIndex)
        }

        let html = generateHTML(using: reportChapters)
        let data = html.data(using: .utf8)!
        return AilmentReport(filename: filename, data: data)
    }
}

// MARK: - HTML Report Generation
extension AilmentReporter {
    private static func generateHTML(using reportChapters: [AilmentSector]) -> HTML {
        var html = "<html>"
        html += header()
        html += "<body>"
        html += "<main class=\"container\">"

        html += menu(using: reportChapters)
        html += mainContent(using: reportChapters)

        html += "</main>"
        html += footer()
        html += "</body>"
        return html
    }

    private static func header() -> HTML {
        var html = "<head>"
        html += "<title>\(Bundle.appName) - Ailment Report</title>"
        html += style()
        html += footerStyle()
        html += scripts()
        html += "<meta charset=\"utf-8\">"
        html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        html += "</head>"
        return html
    }

    private static func footer() -> HTML {
        return """
        <footer id=\"footer\" className=\"footer\" role=\"contentinfo\" aria-labelledby=\"footer-label\">
            <div className=\"footer-content\">
                <section className=\"footer-mini\" vocab=\"http://schema.org/\" typeof=\"Organization\">
                    <div className=\"footer-mini-news\">
                        <div className=\"content\">
                            <div className=\"color-scheme-toggle\" role=\"radiogroup\" tabIndex={0} aria-label=\"Select a color scheme preference.\">
                                <label data-color-scheme-option=\"light\">
                                    <input type=\"radio\" name=\"colorToggle\" value=\"light\" autoComplete=\"off\" />
                                    <div className=\"text\">Light</div>
                                </label>
                                <label data-color-scheme-option=\"dark\">
                                    <input type=\"radio\" name=\"colorToggle\" value=\"dark\" autoComplete=\"off\" />
                                    <div className=\"text\">Dark</div>
                                </label>
                                <label data-color-scheme-option=\"auto\">
                                    <input type=\"radio\" name=\"colorToggle\" value=\"auto\" autoComplete=\"off\" />
                                    <div className=\"text\">Auto</div>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div className=\"footer-mini-legal\">
                        <div className=\"footer-mini-legal-copyright\">Copyright &copy; 2023 <a href=\"https://github.com/nanashili\" target=\"_blank\" rel=\"noreferrer\">Nanashi Li</a> All rights reserved.</div>
                    </div>
                </section>
            </div>
        </footer>
        """
    }

    static func style() -> HTML {
        guard let cssURL = Bundle.module.url(forResource: "style.css", withExtension: nil), let css = try? String(contentsOf: cssURL) else {
            return ""
        }
        return "<style>\(css)</style>"
    }

    static func footerStyle() -> HTML {
        guard let cssURL = Bundle.module.url(forResource: "footer.css", withExtension: nil), let css = try? String(contentsOf: cssURL) else {
            return ""
        }
        return "<style>\(css)</style>"
    }

    static func scripts() -> HTML {
        guard let scriptsURL = Bundle.module.url(forResource: "functions.js", withExtension: nil), let scripts = try? String(contentsOf: scriptsURL) else {
            return ""
        }
        return "<script type=\"text/javascript\">\(scripts)</script>"
    }

    static func menu(using chapters: [AilmentSector]) -> HTML {
        var html = "<aside class=\"nav-container\"><nav><ul>"
        chapters.forEach { chapter in
            html += "<li><a href=\"#\(chapter.title.anchor)\">\(chapter.title)</a></li>"
        }
        html += "<li><button id=\"expand-sections\">Expand sessions</button></li>"
        html += "<li><button id=\"collapse-sections\">Collapse sessions</button></li>"
        html += "<li><input type=\"checkbox\" id=\"system-logs\" name=\"system-logs\" checked><label for=\"system-logs\">Show system logs</label></li>"
        html += "<li><input type=\"checkbox\" id=\"error-logs\" name=\"error-logs\" checked><label for=\"error-logs\">Show error logs</label></li>"
        html += "<li><input type=\"checkbox\" id=\"debug-logs\" name=\"debug-logs\" checked><label for=\"debug-logs\">Show debug logs</label></li>"
        html += "</ul></nav></aside>"
        return html
    }

    static func mainContent(using chapters: [AilmentSector]) -> HTML {
        var html = "<div class=\"main-content\">"
        html += "<header><h1>\(reportTitle)</h1></header>"
        chapters.forEach { chapter in
            html += chapter.html()
        }
        html += "</div>"
        return html
    }
}
