//
//  Device.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

enum Device {
    static var systemName: String {
        #if os(macOS)
        return ProcessInfo().hostName
        #else
        return UIDevice.current.systemName
        #endif
    }

    static var systemVersion: String {
        #if os(macOS)
        return ProcessInfo().operatingSystemVersionString
        #else
        return UIDevice.current.systemVersion
        #endif
    }

    static var freeDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }

    static var totalDiskSpace: String {
        ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }

    static var totalDiskSpaceInBytes: Int64 {
        guard let space = try? URL(fileURLWithPath: NSHomeDirectory() as String)
            .resourceValues(forKeys: [URLResourceKey.volumeTotalCapacityKey])
            .volumeTotalCapacity else {
            return 0
        }
        return Int64(space)
    }

    static var freeDiskSpaceInBytes: Int64 {
        guard let space = try? URL(fileURLWithPath: NSHomeDirectory() as String)
            .resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForOpportunisticUsageKey])
            .volumeAvailableCapacityForOpportunisticUsage else {
            return 0
        }
        return space
    }
}
