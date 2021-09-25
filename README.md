[![Build and test](https://github.com/appintheair/MRZScanner/actions/workflows/Build%20and%20test.yml/badge.svg?branch=develop)](https://github.com/appintheair/MRZScanner/actions/workflows/Build%20and%20test.yml)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/appintheair/MRZParser/blob/develop/Package.swift)
[![codecov](https://codecov.io/gh/appintheair/MRZScanner/branch/develop/graph/badge.svg?token=BAvvoujCum)](https://codecov.io/gh/appintheair/MRZScanner)

# MRZScanner
Library for scanning documents via [MRZ](https://en.wikipedia.org/wiki/Machine-readable_passport) using [ Vision API](https://developer.apple.com/documentation/vision/vnrecognizetextrequest).

## Example
The example project is located inside the [Example](https://github.com/appintheair/MRZScanner/tree/develop/Example) folder. 

![gif](https://github.com/appintheair/MRZScanner/blob/develop/docs/img/example.gif)

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
Currently there are 2 scanners available, `LiveMRZScanner` and `ImageMRZScanner`.
The first is used to scan the MRZ code on a single image, and the second in real-time scanning.

To scan, you need to call the `scanFrame` / `scan` method of the scanner.

## License
The library is distributed under the MIT [LICENSE](https://opensource.org/licenses/MIT).
