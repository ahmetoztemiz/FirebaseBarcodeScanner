//
//  BarcodeVC.swift
//  Flash Chat
//
//  Created by Yasir Balı on 25.12.2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeVC: UIViewController,BarcodeScannerDelegate {

    @IBOutlet weak var secondView: UIView!
    var barcodeScanner: BarcodeScanner?
    
    @IBOutlet weak var immm: UIImageView!
    @IBOutlet weak var labell: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        barcodeScanner = BarcodeScanner.init(scannerView: secondView)
        barcodeScanner?.delegate = self
        barcodeScanner?.startScanningBarcode()
       
    }
    
    func BarcodeScannerDidCaptureCode(code: String) {
        print(code)
        labell.text = code
    }

    //flashlight
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = (device.torchMode == .on) ? .off : .on
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}
