//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

public enum Catcher {
    @discardableResult
    public static func `catch`<T>(callback: () throws -> T) throws -> T {
        var returnValue: T!
        var returnError: Error?

        try ExceptionCatcher.catchException {
            do {
                returnValue = try callback()
            } catch {
                returnError = error
            }
        }

        if let returnError {
            throw returnError
        }

        return returnValue
    }
}

class ExceptionCatcher: NSObject {
    static func catchException(_ tryBlock: () -> Void) throws -> Bool {
        do {
            tryBlock()
            return true
        } catch let exception as NSException {
            let error = NSError(domain: exception.name.rawValue, code: 0, userInfo: [
                NSUnderlyingErrorKey: exception,
                NSLocalizedDescriptionKey: exception.reason ?? "",
                "CallStackSymbols": exception.callStackSymbols
            ])
            throw error
        }
    }
}
