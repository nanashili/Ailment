//
//  UserDefaultsReporter.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

/// Generates a report from all the registered UserDefault keys.
public final class UserDefaultsReporter: AilmentReporting {

    /// Defaults to `standard`. Can be used to override and return a different user defaults.
    public static var userDefaults: UserDefaults = .standard

    public init() { }

    public func report() -> AilmentSector {
        let userDefaults = Self.userDefaults.dictionaryRepresentation()
        return AilmentSector(title: "UserDefaults", diagnostics: userDefaults, formatter: Self.self)
    }
}

extension UserDefaultsReporter: HTMLFormatting {
    public static func format(_ diagnostics: Ailment) -> HTML {
        guard let userDefaultsDict = diagnostics as? [String: Any] else { return diagnostics.html() }
        return "<pre>\(userDefaultsDict.jsonRepresentation ?? "Could not parse User Defaults")</pre>"
    }
}

private extension Dictionary where Key == String, Value == Any {
    var jsonRepresentation: String? {
        let options: JSONSerialization.WritingOptions
        if #available(iOS 11.0, *) {
            options = [.prettyPrinted, .sortedKeys, .fragmentsAllowed]
        } else {
            options = [.prettyPrinted, .fragmentsAllowed]
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonCompatible, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }

    var jsonCompatible: [String: Any] {
        return mapValues { value -> Any in
            if let dict = value as? [String: Any] {
                return dict.jsonCompatible
            } else if let array = value as? [Any] {
                return array.map { "\($0)" }
            }

            return "\(value)"
        }
    }
}
