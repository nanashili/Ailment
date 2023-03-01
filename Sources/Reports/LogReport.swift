//
//  LogReport.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

/// Creates a report chapter for all system and custom logs captured with the `AilmentLogger`.
struct LogReport: AilmentReporting {

    let title: String = "Session Logs"

    var diagnostics: String {
        guard let data = AilmentLogger.standard.readLog(), let logs = String(data: data, encoding: .utf8) else {
            return "Parsing the log failed"
        }

        let sessions = logs.components(separatedBy: "\n\n---\n\n").reversed()
        var diagnostics = ""
        sessions.forEach { session in
            guard !session.isEmpty else { return }

            diagnostics += "<div class=\"collapsible-session\">"
            diagnostics += "<details>"
            if session.isOldStyleSession {
                let title = session.split(whereSeparator: \.isNewline).first ?? "Unknown session title"
                diagnostics += "<summary>\(title)</summary>"
                diagnostics += "<pre>\(session.addingHTMLEncoding())</pre>"
            } else {
                diagnostics += session
            }
            diagnostics += "</details>"
            diagnostics += "</div>"
        }
        return diagnostics
    }

    func report() -> AilmentSector {
        return AilmentSector(title: title, diagnostics: diagnostics, formatter: Self.self)
    }
}

extension LogReport: HTMLFormatting {
    static func format(_ diagnostics: Ailment) -> HTML {
        return "<div id=\"log-sessions\">\(diagnostics)</div>"
    }
}

private extension String {
    var isOldStyleSession: Bool {
        !contains("class=\"session-header")
    }
}
