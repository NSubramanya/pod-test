//
//  ScannerViewController.swift
//  ScanDemo
//
//  Created by sukhjeet singh sandhu on 27/07/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

import UIKit
import CML_SCAN
import AVFoundation

protocol BarcodeReceived: class {
    func barcodeReceived(barcode: String, barcodeType: String)
}

class ScannerViewController: UIViewController, BarcodeScannerDelegate {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!

    weak var delegate: BarcodeReceived?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let types = [Types.qrCode, Types.code128, Types.code39, Types.ean13, Types.ean8, Types.dataMatrix]
        (self.view as! ScanView).startScanning(with: types) { error in
            if let error = error {
                self.alert(with: error)
            }
        }
        (self.view as! ScanView).should(vibrate: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        (self.view as! ScanView).barcodeDelegate = self
        self.view.bringSubview(toFront: self.switchCameraButton)
        self.view.bringSubview(toFront: self.dismissButton)
    }

    fileprivate func alert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                                      handler: {[weak self](alert: UIAlertAction!) in
                                        self?.dismiss(animated: true, completion: nil)
        }))
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func switchCamera(_ sender: UIButton) {
        (self.view as! ScanView).switchCamera()
    }
    
    func didReceiveBarcode(barcode: String?, barcodeType: String?) {
        if let barcode = barcode,
        let barcodeType = barcodeType {
            self.delegate?.barcodeReceived(barcode: barcode, barcodeType: barcodeType)
            self.dismiss(animated: true, completion: nil)
        } else {
            self.alert(with: "Barcode not found")
        }
    }
}

