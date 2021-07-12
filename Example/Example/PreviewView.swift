//
//  PreviewView.swift
//  Example
//
//  Created by Roman Mazeev on 28.06.2021.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("""
                       Expected `AVCaptureVideoPreviewLayer` type for layer.
                       Check PreviewView.layerClass implementation.
                       """)
        }

        return layer
    }

    var session: AVCaptureSession? {
        get { videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }

    // MARK: UIView

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}
