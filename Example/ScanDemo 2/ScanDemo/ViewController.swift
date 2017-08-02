//
//  ViewController.swift
//  ScanDemo
//
//  Created by sukhjeet singh sandhu on 31/07/17.
//  Copyright © 2017 Solcen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BarcodeReceived {

    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var barcodeTypeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func scan(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "scanner") as! ScannerViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    func barcodeReceived(barcode: String, barcodeType: String) {
        self.barcodeLabel.text = barcode
        self.barcodeTypeLabel.text = barcodeType
    }
}
