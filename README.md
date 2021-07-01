[![Swift](https://github.com/appintheair/MRZScanner/actions/workflows/swift.yml/badge.svg)](https://github.com/appintheair/MRZScanner/actions/workflows/swift.yml)
# MRZScanner
Library for scanning documents via [MRZ](https://en.wikipedia.org/wiki/Machine-readable_passport) using [ Vision API](https://developer.apple.com/documentation/vision).

## Requirements
* iOS 13.0+
* macOS 10.15+
* Mac Catalyst 13.0+
* tvOS 13.0+

## Installation guide
### Swift Package Manager
```swift
dependencies: [
    .package(url: "git@github.com:appintheair/MRZParser.git", .upToNextMajor(from: "0.0.1"))
]
```
The library has an SPM [dependency](https://github.com/appintheair/MRZParser) for MRZ code parsing 

## Usage
**First, we need to initialize the scanner**
```swift
let scanner = MRZScanner()
```
**Next, we need to add a `MRZScannerDelegate` protocol match and implement the following delegate methods**
```swift
class ViewController: MRZScannerDelegate {
    // 1
    func mrzScanner(_ scanner: MRZScanner, didFinishWith result: Result<ScanningResult, Error>)
    // 2
    func mrzScanner(_ scanner: MRZScanner, didFindBoundingRects rects: (invalid: [CGRect], valid: [CGRect]))
}
```
1. Transmits the result of a scan when it is complete (successful/failed
2. Passes the boundaries of the recognized text (those that are supposed to be MRZ strings, and those that are not)

**Set yourself up as a scanner delegate And call `scan(pixelBuffer:, orientation:, regionOfInterest:)` method, which starts the scanning of the passed [CVImageBuffer](https://developer.apple.com/documentation/corevideo/cvimagebuffer-q40) using [CGImagePropertyOrientation](https://developer.apple.com/documentation/imageio/cgimagepropertyorientation) and regionOfInterest: [CGRect](https://developer.apple.com/documentation/coregraphics/cgrect)**
```swift
scanner.delegate = self
scanner.scan(pixelBuffer: pixelBuffer, orientation: orientation, regionOfInterest: regionOfInterest)
```

## Example
The example project is located inside the `Example` folder. To run it, you need a device with the minimum required OS version.
![gif](https://raw.githubusercontent.com/appintheair/MRZScanner/develop/docs/img/example.png)

## License
The library is distributed under the MIT [LICENSE](https://opensource.org/licenses/MIT).
