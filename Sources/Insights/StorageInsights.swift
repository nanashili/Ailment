//
//  StorageInsights.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//

import Foundation

struct StorageInsights: IInsightSection {

    static let threshold: Int64 = 1000 * 1000 * 1000 // 1GB

    let sectionName: String = "Storage"
    let sectionResult: InsightResult

    init(freeDiskSpace: Int64 = Device.freeDiskSpaceInBytes,
         totalDiskSpace: String = Device.totalDiskSpace) {
        let lowOnStorage = freeDiskSpace <= StorageInsights.threshold

        let freeDiskSpaceString = ByteCountFormatter.string(fromByteCount: freeDiskSpace, countStyle: ByteCountFormatter.CountStyle.decimal)

        let storageStatus = "(\(freeDiskSpaceString) of \(totalDiskSpace) left)"

        if lowOnStorage {
            self.sectionResult = .warn(message: "The user is low on storage \(storageStatus)")
        } else {
            self.sectionResult = .success(message: "The user has enough storage \(storageStatus)")
        }
    }
}
