//
//  Ailment.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

/// Defines supported `Ailment` to generate a report from.
public protocol Ailment: HTMLGenerator { }
extension Dictionary: Ailment where Key == String { }
extension KeyValuePairs: Ailment where Key == String, Value == String { }
extension String: Ailment {}
