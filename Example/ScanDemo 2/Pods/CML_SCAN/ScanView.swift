//
//  ScanView.swift
//  SCAN
//
//  Created by sukhjeet singh sandhu on 27/07/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

// These are the barcode types, those are supported by this Pod.
public enum Types {
    case qrCode
    case dataMatrix
    case ean8
    case ean13
    case code128
    case code39
}

// This protocol is responsibe for providing the barcode and type back to the view controller.
public protocol BarcodeScannerDelegate: class {
    func didReceiveBarcode(barcode: String?, barcodeType: String?)
}

open class ScanView: UIView {

    var isBackCamera = true

    fileprivate var session: AVCaptureSession!
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate var interestRect: CGRect!
    fileprivate var error: String?

    var supportedTypes: [String] = []
    var shouldVibrateOnScan = true
    var topMask: UIView!
    var bottomMask: UIView!
    var leftMask: UIView!
    var rightMask: UIView!
    var topLHLine: UIView!
    var topRHLine: UIView!
    var bottomLHLine: UIView!
    var bottomRHLine: UIView!
    var topLVLine: UIView!
    var topRVLine: UIView!
    var bottomLVLine: UIView!
    var bottomRVLine: UIView!
    var currentOrientation: UIDeviceOrientation?
    var captureDevice: AVCaptureDevice?

    open weak var barcodeDelegate: BarcodeScannerDelegate?

    // This function should be called, in order to start scanning with supported barcode types as parameter.
    open func startScanning(with types: [Types], onError: ((String?)->())) {
        NotificationCenter.default.addObserver(self, selector: #selector(ScanView.handleRotation), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        self.backgroundColor = .white
        self.setSupportesTypes(from: types)
        self.loadSubViews()
        self.scan()
        if let error = self.error {
            onError(error)
            self.error = nil
        } else {
            onError(nil)
        }
    }

    // Call this function to switch the camera from back to front or vice-versa.
    open func switchCamera() {
        isBackCamera = !isBackCamera
        self.scan()
    }
    
    // Call this method to turn vibration on or off with a parameter of type Bool.
    open func should(vibrate beTurnedOn: Bool) {
        self.shouldVibrateOnScan = beTurnedOn
    }

    func scan() {
        self.session = AVCaptureSession()
        if let _ = self.previewLayer {
            self.previewLayer.frame = self.bounds
        }
        self.provideInputDevice()
    }
    
    func provideInputDevice() {
        do {
            
            self.setCaptureDevice()
            let input = try AVCaptureDeviceInput(device: captureDevice)
            self.session.addInput(input)
            self.ProvideOutputToGetPreviewLayer()
            self.previewLayer.frame = self.frame
            self.manageViews()
        } catch {
            self.error = "Cannot access Camera. Please, check if camera access is provided in the settings."
        }
    }

    func setCaptureDevice() {
        var captureDevice: AVCaptureDevice?
        let devices = AVCaptureDevice.devices()
        for dev in devices! {
            let device = dev as! AVCaptureDevice
            if isBackCamera {
                if device.position == .back {
                    captureDevice = device
                }
            } else {
                if (device as AnyObject).position == .front {
                    captureDevice = device
                }
            }
        }
        self.captureDevice = captureDevice
    }
    
    func ProvideOutputToGetPreviewLayer() {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.session.addOutput(output)
        output.metadataObjectTypes = self.supportedTypes
        output.rectOfInterest = interestRect
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer = previewLayer!
        if isBackCamera == false {
            self.previewLayer.connection.automaticallyAdjustsVideoMirroring = false
            self.previewLayer.connection.isVideoMirrored = false
        }
        self.session.startRunning()
    }

    func setSupportesTypes(from types: [Types]) {
        for type in types {
            switch type {
            case .qrCode:
                self.supportedTypes.append(AVMetadataObjectTypeQRCode)
            case .ean8:
                self.supportedTypes.append(AVMetadataObjectTypeEAN8Code)
            case .ean13:
                self.supportedTypes.append(AVMetadataObjectTypeEAN13Code)
            case .code128:
                self.supportedTypes.append(AVMetadataObjectTypeCode128Code)
            case .code39:
                self.supportedTypes.append(AVMetadataObjectTypeCode39Code)
            case .dataMatrix:
                self.supportedTypes.append(AVMetadataObjectTypeDataMatrixCode)
            }
        }
    }

    func loadSubViews() {
        let sideOfInterestRect = min(min(self.bounds.width, self.bounds.height) - 50.0, 300)
        self.topMask = UIView(frame: CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width, height: self.bounds.height/2 - (sideOfInterestRect/2)))
        self.bottomMask = UIView(frame: CGRect(x: self.bounds.minX, y: self.bounds.midY + (sideOfInterestRect/2), width: self.bounds.width, height: self.bounds.height/2 - (sideOfInterestRect/2)))
        self.leftMask = UIView(frame: CGRect(x: self.bounds.minX, y: self.bounds.midY - (sideOfInterestRect/2), width: self.bounds.width/2 - (sideOfInterestRect/2), height: sideOfInterestRect))
        self.rightMask = UIView(frame: CGRect(x: self.bounds.midX + (sideOfInterestRect/2), y: self.bounds.midY - (sideOfInterestRect/2), width: self.bounds.width/2 - (sideOfInterestRect/2), height: sideOfInterestRect))
        self.topLVLine = UIView(frame: CGRect(x: self.bounds.midX - (sideOfInterestRect/2), y: self.bounds.midY - (sideOfInterestRect/2), width: 3.0 , height: 35.0))
        self.bottomLVLine = UIView(frame: CGRect(x: self.bounds.midX - (sideOfInterestRect/2), y: self.bounds.midY + ((sideOfInterestRect/2) - 35.0), width: 3.0 , height: 35.0))
        self.topRVLine = UIView(frame: CGRect(x: self.bounds.midX + ((sideOfInterestRect/2) - 3.0), y: self.bounds.midY - (sideOfInterestRect/2), width: 3.0 , height: 35.0))
        self.bottomRVLine = UIView(frame: CGRect(x: self.bounds.midX + ((sideOfInterestRect/2) - 3.0), y: self.bounds.midY + ((sideOfInterestRect/2) - 35.0), width: 3.0 , height: 35.0))
        self.topLHLine = UIView(frame: CGRect(x: self.bounds.midX - (sideOfInterestRect/2), y: self.bounds.midY - (sideOfInterestRect/2), width: 35.0 , height: 3.0))
        self.topRHLine = UIView(frame: CGRect(x: self.bounds.midX + ((sideOfInterestRect/2) - 35.0), y: self.bounds.midY - (sideOfInterestRect/2), width: 35.0 , height: 3.0))
        self.bottomLHLine = UIView(frame: CGRect(x: self.bounds.midX - (sideOfInterestRect/2), y: self.bounds.midY + ((sideOfInterestRect/2) - 3.0), width: 35.0 , height: 3.0))
        self.bottomRHLine = UIView(frame: CGRect(x: self.bounds.midX + ((sideOfInterestRect/2) - 35.0), y: self.bounds.midY + ((sideOfInterestRect/2) - 3.0), width: 35.0 , height: 3.0))
        
        self.setColor()
        self.addSubview(topMask)
        self.addSubview(bottomMask)
        self.addSubview(leftMask)
        self.addSubview(rightMask)
        self.addSubview(topRHLine)
        self.addSubview(topLHLine)
        self.addSubview(topRVLine)
        self.addSubview(topLVLine)
        self.addSubview(bottomRHLine)
        self.addSubview(bottomLHLine)
        self.addSubview(bottomLVLine)
        self.addSubview(bottomRVLine)
        self.interestRect = CGRect(x: 0.5 - (150/self.bounds.width), y: 0.5 - (150/self.bounds.height), width: 300 / self.bounds.width, height: 300 / self.bounds.height)
    }

    func setColor() {
        self.topMask.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.75)
        self.bottomMask.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.75)
        self.leftMask.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.75)
        self.rightMask.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.75)
        self.topLHLine.backgroundColor = .blue
        self.topRHLine.backgroundColor = .blue
        self.topLVLine.backgroundColor = .blue
        self.topRVLine.backgroundColor = .blue
        self.bottomRHLine.backgroundColor = .blue
        self.bottomLHLine.backgroundColor = .blue
        self.bottomRVLine.backgroundColor = .blue
        self.bottomLVLine.backgroundColor = .blue
    }

    func handleRotation() {
        let orientation = UIApplication.shared.statusBarOrientation
        if let _ = self.previewLayer {
            switch orientation {
            case .portrait:
                self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            case .portraitUpsideDown:
                self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            case .landscapeLeft:
                self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            case .landscapeRight:
                self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            default:
                break
            }
        }
        self.removeSubViews()
        self.previewLayer.frame = self.bounds
        self.loadSubViews()
    }

    fileprivate func manageViews() {
        self.layer.addSublayer(self.previewLayer)
        self.bringSubview(toFront: self.topMask)
        self.bringSubview(toFront: self.bottomMask)
        self.bringSubview(toFront: self.leftMask)
        self.bringSubview(toFront: self.rightMask)
        self.bringSubview(toFront: self.topRHLine)
        self.bringSubview(toFront: self.topRVLine)
        self.bringSubview(toFront: self.topLHLine)
        self.bringSubview(toFront: self.topLVLine)
        self.bringSubview(toFront: self.bottomRHLine)
        self.bringSubview(toFront: self.bottomLHLine)
        self.bringSubview(toFront: self.bottomRVLine)
        self.bringSubview(toFront: self.bottomLVLine)
    }

    func removeSubViews() {
        self.topMask.removeFromSuperview()
        self.bottomMask.removeFromSuperview()
        self.leftMask.removeFromSuperview()
        self.rightMask.removeFromSuperview()
        self.topLHLine.removeFromSuperview()
        self.topLVLine.removeFromSuperview()
        self.topRHLine.removeFromSuperview()
        self.topRVLine.removeFromSuperview()
        self.bottomLHLine.removeFromSuperview()
        self.bottomLVLine.removeFromSuperview()
        self.bottomRHLine.removeFromSuperview()
        self.bottomRVLine.removeFromSuperview()
    }
}

extension ScanView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metaDataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureOutput.rectForMetadataOutputRect(ofInterest: self.interestRect)
        for data in metaDataObjects {
            let metadata = data as AnyObject
            for type in self.supportedTypes {
                if metadata.type == type {
                    if let detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue {
                        print(detectionString)
                        if shouldVibrateOnScan {
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                        var barcodeType = ((metadata as! AVMetadataMachineReadableCodeObject).type).trimmingCharacters(in: .init(charactersIn: "org.iso."))
                        if barcodeType == "1.EAN-8" || barcodeType == "1.EAN-13" {
                            barcodeType = barcodeType.trimmingCharacters(in: .init(charactersIn: "1."))
                        }
                        self.barcodeDelegate?.didReceiveBarcode(barcode: detectionString, barcodeType: barcodeType)
                        print(barcodeType)
                    } else {
                        self.barcodeDelegate?.didReceiveBarcode(barcode: nil, barcodeType: nil)
                    }
                    break
                }
            }
        }
        
    }
}
