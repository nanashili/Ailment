//
//  File.swift
//  
//
//  Created by Nanashi Li on 01/03/2023.
//
import Foundation
import MetricKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A  `Ailment` Logger to log messages to which will end up in the Diagnostics Report if using the default `LogsReporter`.
/// Will keep a `.txt` log in the documents directory with the latestlogs with a max size of 2 MB.
public final class AilmentLogger {
    static let standard = AilmentLogger()

    private lazy var logFileLocation: URL = FileManager.default.documentsDirectory.appendingPathComponent("ailment.txt")

    private let inputPipe: Pipe = Pipe()
    private let outputPipe: Pipe = Pipe()

    private let queue: DispatchQueue = DispatchQueue(
        label: "com.ailment.logger",
        qos: .utility,
        autoreleaseFrequency: .workItem,
        target: .global(qos: .utility)
    )

    private var logSize: Int64!
    private let maximumSize: Int64 = 2 * 1024 * 1024 // 2 MB
    private let trimSize: Int64 = 100 * 1024 // 100 KB
    private let minimumRequiredDiskSpace: Int64 = 500 * 1024 * 1024 // 500 MB
    private var logLinesPassedSinceLastDiskCheck = 0

    /// Makes sure we have enough disk space left for new logs, preventing a crash due to a lack of space.
    /// Comes with a threshold to check for free disk space since iOS 16+ triggers system logs during space
    /// checking that we handle as logs as well.
    /// Not adding this threshold would mean ending up in an infinite loop on iOS 16 and up.
    /// `logLinesPassedSinceLastDiskCheck` is thread safe since this method is only accessed from our serial queue.
    private var canWriteNewLogs: Bool {
        guard logLinesPassedSinceLastDiskCheck >= 5 else {
            return true
        }
        defer { logLinesPassedSinceLastDiskCheck = 0 }
        guard Device.freeDiskSpaceInBytes > minimumRequiredDiskSpace else {
            return false
        }
        return true
    }

    private var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private lazy var metricsMonitor: MetricsMonitor = MetricsMonitor()

    /// Whether the logger is setup and ready to use.
    private var isSetup: Bool = false

    /// Whether the logger is setup and ready to use.
    public static func isSetUp() -> Bool {
        return standard.isSetup
    }

    /// Sets up the logger to be ready for usage. This needs to be called before any log messages are reported.
    /// This method also starts a new session.
    public static func setup() throws {
        guard !isSetUp() || standard.isRunningTests else {
            return
        }
        try standard.setup()
    }

    /// Logs the given message for the diagnostics report.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - file: The file from which the log is send. Defaults to `#file`.
    ///   - function: The functino from which the log is send. Defaults to `#function`.
    ///   - line: The line from which the log is send. Defaults to `#line`.
    public static func log(message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        standard.log(LogItem(.debug(message: message), file: file, function: function, line: line))
    }

    /// Logs the given error for the diagnostics report.
    /// - Parameters:
    ///   - error: The error to log.
    ///   - description: An optional description parameter to add extra info about the error.
    ///   - file: The file from which the log is send. Defaults to `#file`.
    ///   - function: The functino from which the log is send. Defaults to `#function`.
    ///   - line: The line from which the log is send. Defaults to `#line`.
    public static func log(
        error: Error,
        description: String? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        standard.log(LogItem(.error(error: error, description: description), file: file, function: function, line: line))
    }
}

// MARK: - Setup
extension AilmentLogger {

    private func setup() throws {
        if !FileManager.default.fileExists(atPath: logFileLocation.path) {
            try FileManager.default
                .createDirectory(atPath: FileManager.default.documentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
            guard FileManager.default.createFile(atPath: logFileLocation.path, contents: nil, attributes: nil) else {
                assertionFailure("Unable to create the log file")
                return
            }
        }

        let logFileHandle = try FileHandle(forWritingTo: logFileLocation)
        logFileHandle.seekToEndOfFile()
        logSize = Int64(logFileHandle.offsetInFile)
        setupPipe()
        metricsMonitor.startMonitoring()
        isSetup = true
        startNewSession()
    }
}

// MARK: - Setup & Logging
extension AilmentLogger {

    /// Creates a new section in the overall logs with data about the session start and system information.
    func startNewSession() {
        log(NewSession())
    }

    /// Reads the log and converts it to a `Data` object.
    func readLog() -> Data? {
        guard isSetup else {
            assertionFailure("Trying to read the log while not set up")
            return nil
        }

        return queue.sync {
            let coordinator = NSFileCoordinator(filePresenter: nil)
            var error: NSError?
            var logData: Data?
            coordinator.coordinate(readingItemAt: logFileLocation, error: &error) { url in
                logData = try? Data(contentsOf: url)
            }
            return logData
        }
    }

    /// Removes the log file. Should only be used for testing purposes.
    func deleteLogs() throws {
        guard FileManager.default.fileExists(atPath: logFileLocation.path) else { return }
        try? FileManager.default.removeItem(atPath: logFileLocation.path)
    }

    func log(_ loggable: Loggable) {
        guard isSetup else {
            return assertionFailure("Trying to log a message while not set up")
        }

        queue.async { [weak self] in
            guard let self = self else { return }
            let coordinator = NSFileCoordinator(filePresenter: nil)
            var error: NSError?
            coordinator.coordinate(writingItemAt: self.logFileLocation, error: &error) { [weak self] url in
                do {
                    guard let self = self, self.canWriteNewLogs else { return }

                    guard let data = loggable.logData else {
                        return assertionFailure("Missing file handle or invalid output logged")
                    }

                    let fileHandle = try FileHandle(forWritingTo: url)
                    if #available(OSX 10.15.4, iOS 13.4, watchOS 6.0, tvOS 13.4, *) {
                        defer {
                            try? fileHandle.close()
                        }
                        try fileHandle.seekToEnd()
                        try fileHandle.write(contentsOf: data)
                    } else {
                        self.legacyAppend(data, to: fileHandle)
                    }

                    self.logSize += Int64(data.count)
                    self.trimLinesIfNecessary()
                } catch {
                    print("Writing data failed with error: \(error)")
                }
            }
        }
    }

    private func legacyAppend(_ data: Data, to fileHandle: FileHandle) {
        defer {
            fileHandle.closeFile()
        }
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
    }

    private func trimLinesIfNecessary() {
        guard logSize > maximumSize else { return }

        guard
            var data = try? Data(contentsOf: self.logFileLocation, options: .mappedIfSafe),
            !data.isEmpty,
            let newline = "\n".data(using: .utf8) else {
                return assertionFailure("Trimming the current log file failed")
        }

        var position: Int = 0
        while (logSize - Int64(position)) > (maximumSize - trimSize) {
            guard let range = data.firstRange(of: newline, in: position ..< data.count) else { break }
            position = range.startIndex.advanced(by: 1)
        }

        logSize -= Int64(position)
        data.removeSubrange(0 ..< position)

        guard (try? data.write(to: logFileLocation, options: .atomic)) != nil else {
            return assertionFailure("Could not write trimmed log to target file location: \(logFileLocation)")
        }
    }
}

// MARK: - System logs
private extension AilmentLogger {

    func setupPipe() {
        guard !isRunningTests else { return }

        inputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            self?.handleLoggedData(data)
        }

        // Copy the STDOUT file descriptor into our output pipe's file descriptor
        // So we can write the strings back to STDOUT and it shows up again in the Xcode console.
        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)

        // Send all output (STDOUT and STDERR) to our `Pipe`.
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    }

    private func handleLoggedData(_ data: Data) {
        do {
            try Catcher.catch { () -> Void in
                autoreleasepool {
                    outputPipe.fileHandleForWriting.write(data)

                    guard let string = String(data: data, encoding: .utf8) else {
                        return assertionFailure("Invalid data is logged")
                    }

                    string.enumerateLines(invoking: { [weak self] (line, _) in
                        self?.log(SystemLog(line: line))
                    })
                }
            }
        } catch {
            print("Exception was catched \(error)")
        }
    }
}

private extension FileManager {
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func fileExistsAndIsFile(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        if fileExists(atPath: path, isDirectory: &isDirectory) {
            return !isDirectory.boolValue
        } else {
            return false
        }
    }
}
