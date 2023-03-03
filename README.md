# Ailment

The `Ailment` library is a Swift-based tool that simplifies the process of sharing diagnostic reports with your support team.

`Ailment` - The term "ailment" generally refers to a minor illness or health condition that is not severe enough to be classified as a disease. It is often used to describe symptoms or discomfort that can be treated with medication or other forms of therapy, but that do not require hospitalization or more intensive medical intervention. In the context of the Ailment library, an "ailment" refers to a specific issue or problem that is identified and reported through the library's diagnostic tools.

## TODO

It is planned to add the following features to `Ailment` in the future:

- [ ] Custom UI to send `Ailment` reports to your support team
- [ ] More detailed and customizable reports for common issues such as memory leaks and UI performance problems.
- [ ] Clean up the HTML reporting style to follow a more `Apple` like design.
- [ ] The ability to export reports in various formats, such as PDF or CSV.
- [ ] Better documentation and examples to make it easier for developers to get started and use the library effectively.

## Usage

The default report contains substantial and pertinent information, which may suffice for the purpose at hand. 

It is imperative to initialize the `AilmentLogger` as early as feasible to capture all system logs, such as in the `didLaunchWithOptions` method:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try AilmentLogger.setup()
    } catch {
        print("Failed to setup the Diagnostics Logger")
    }
    return true
}
```

### Using a custom UserDefaults type

Simply set your user defaults instance by making use of:

```swift
UserDefaultsReporter.userDefaults = ..
```

### The process of filtering sensitive data from the Ailment report.

To ensure that sensitive data is not included in the diagnostic report, you may create a `AilmentFilter`.

```swift
struct AilmentDictionaryFilter: AilmentFilter {
    static func filter(_ diagnostics: Ailment) -> Ailment {
        guard let dictionary = diagnostics as? [String: Any] else { return diagnostics }
        return dictionary.filter { keyValue -> Bool in
            if keyValue.key == "App Display Name" {
                // Filter out the key with the value "App Display Name"
                return false
            } else if keyValue.key == "AppleLanguages" {
                // Filter out a user defaults key.
                return false
            }
            return true
        }
    }
}
```

Which can be used by passing in the filter into the `create(..)` method:

```swift
let report = AilmentReporter.create(using: reporters, filters: [AilmentFilter.self])
```

### Adding your own custom logs

If the default logs provided by the AilmentLogger are not sufficient for your needs, you can also add your own custom logs. 
This can be achieved by using the log method provided by the AilmentLogger. 
You can pass in any string/error message to this method, and it will be appended to the final diagnostic report. 
This can be useful for capturing application-specific logs or user interactions that may be relevant for debugging purposes.

```swift
/// Support logging simple `String` messages.
AilmentLogger.log(message: "Application started")

/// Support logging `Error` types.
AilmentLogger.log(error: ExampleError.missingData)
```

The error logger utilizes the localized description, if available, which can be added by ensuring that your error conforms to LocalizedError.

### Adding your own report

If you want to add your own custom report, you can implement the `AilmentReporting` protocol. 
This protocol allows you to add your own report to the diagnostic report.

```swift
/// An example Custom Reporter.
struct CustomReporter: AilmentReporting {
    static func report() -> AilmentSector {
        let diagnostics: [String: String] = [
            "Logged In": Session.isLoggedIn.description
        ]

        return AilmentSector(title: "My custom report", diagnostics: diagnostics)
    }
}
```

You can then add this report to the creation method:

```swift
var reporters = AilmentReporter.DefaultReporter.allReporters
reporters.insert(CustomReporter.self, at: 1)
let report = AilmentReporter.create(using: reporters)
```

#### Creating a custom HTML formatter for your report

If you wish to customize the way the HTML report is generated, you can implement the `HTMLFormatting` protocol. 
This protocol allows you to modify the structure and content of the generated HTML.

To customize the way the HTML is reported, you can pass in the formatter into the `AilmentSector` initializer.

```swift
AilmentSector(title: "UserDefaults", diagnostics: userDefaults, formatter: <#HTMLFormatting.Type#>)
```

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

#### Manifest File

To add `Ailment` as a package dependency in your Swift project, you can follow these steps:

```swift
import PackageDescription

let package = Package(
    name: "MyProject",
    platforms: [
       .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/nanashili/Ailment.git")
    ],
    targets: [
        .target(
            name: "MyProject",
            dependencies: ["Ailment"]),
        .testTarget(
            name: "MyProjectTests",
            dependencies: ["MyProject"]),
    ]
)
```

## License

Copyright (C) 2023 Nanashi Li

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
