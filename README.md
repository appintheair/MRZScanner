[![Swift](https://github.com/appintheair/MRZScanner/actions/workflows/swift.yml/badge.svg)](https://github.com/appintheair/MRZScanner/actions/workflows/swift.yml)
# MRZScanner
Library for scanning documents via [MRZ](https://en.wikipedia.org/wiki/Machine-readable_passport) using [ Vision API](https://developer.apple.com/documentation/vision/vnrecognizetextrequest).

## Example
The example project is located inside the [Example](https://github.com/appintheair/MRZScanner/tree/develop/Example) folder. 

![gif](https://raw.githubusercontent.com/appintheair/MRZScanner/develop/docs/img/example.png)

*To run it, you need a device with the [minimum required OS version](https://github.com/appintheair/MRZScanner#requirements).*

## Requirements
* iOS 13.0+
* macOS 10.15+
* Mac Catalyst 13.0+
* tvOS 13.0+

## Installation guide
### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/appintheair/MRZScanner.git", .upToNextMajor(from: "0.0.1"))
]
```
*The library has an SPM [dependency](https://github.com/appintheair/MRZParser) for MRZ code parsing.*

## Usage
**First, we need to initialize the [MRZScanner](https://github.com/appintheair/MRZScanner/blob/e1bd20fcfbe64f07053dba35b3d15a1de57970a7/Sources/MRZScanner/MRZScanner.swift#L26)**
```swift
let scanner = MRZScanner()
```

**Next, we need to add a [MRZScannerDelegate](https://github.com/appintheair/MRZScanner/blob/e1bd20fcfbe64f07053dba35b3d15a1de57970a7/Sources/MRZScanner/MRZScanner.swift#L11) protocol match and implement the following delegate methods**
```swift
public protocol MRZScannerDelegate: AnyObject {
    // 1
    func mrzScanner(_ scanner: MRZScanner, didReceiveResult result: ScanningResult)
    // 2
    func mrzScanner(_ scanner: MRZScanner, didFindBoundingRects rects: [CGRect])
}
```
1. Transmits the [ScanningResult](https://github.com/appintheair/MRZScanner/blob/e1bd20fcfbe64f07053dba35b3d15a1de57970a7/Sources/MRZScanner/MRZScanner.swift#L20) when scanning is complete. *Description of the fields in the code*
2. Passes the boundaries of the possible mrz code lines


**To start scanning you need to call [scan](https://github.com/appintheair/MRZScanner/blob/e1bd20fcfbe64f07053dba35b3d15a1de57970a7/Sources/MRZScanner/MRZScanner.swift#L33)**
```swift
scanner.scan(pixelBuffer: pixelBuffer,
             orientation: orientation,
             regionOfInterest: regionOfInterest)
```
*Description of parameters in the code*

**To reset the tracked data need to call [reset](https://github.com/appintheair/MRZScanner/blob/e1bd20fcfbe64f07053dba35b3d15a1de57970a7/Sources/MRZScanner/ResultTracker.swift#L55)**
```swift
scanner.tracker.reset()
```

## License
The library is distributed under the MIT [LICENSE](https://opensource.org/licenses/MIT).
