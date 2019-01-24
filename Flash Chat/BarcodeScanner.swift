//
//  BarcodeScanner.swift
//  Flash Chat
//
//  Created by Yasir Balı on 25.12.2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Firebase
import AVFoundation

protocol BarcodeScannerDelegate: class {
    func BarcodeScannerDidCaptureCode(code: String)
}

class BarcodeScanner: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    weak var scannerView: UIView?
    weak var delegate: BarcodeScannerDelegate?
  
    init(scannerView: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: scannerView.frame.width, height: scannerView.frame.height))
        self.scannerView = scannerView
        scannerView.addSubview(self)
        scannerView.clipsToBounds = true
    }
    
    func startScanningBarcode(){
        
        //CaptureSession
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        if captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
        }else {
            //kullanıcıya uyarı verilebilir cihazınız desteklemiyor diye
            print("error")
            return
        }
        
        let dataOutput = AVCaptureVideoDataOutput()

        if captureSession!.canAddOutput(dataOutput) {
            captureSession!.addOutput(dataOutput)
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        }else {
            //kullanıcıya uyarı verilebilir cihazınız desteklemiyor diye
            print("error")
            return
        }
        
        //PreviewLayer
        previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer!.frame = scannerView?.frame ?? CGRect.zero
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.addSublayer(previewLayer!)
        
        if !(captureSession!.isRunning) {
            captureSession!.startRunning()
        }
    }
    
    func barcodeReader(buffer: CMSampleBuffer){
        
        let format = VisionBarcodeFormat.all
        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
        let vision = Vision.vision()
        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
        
        let metadata = VisionImageMetadata()
        
        // Using back-facing camera
        let devicePosition: AVCaptureDevice.Position = .back
        
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait:
            metadata.orientation = devicePosition == .front ? .leftTop : .rightTop
        case .landscapeLeft:
            metadata.orientation = devicePosition == .front ? .bottomLeft : .topLeft
        case .portraitUpsideDown:
            metadata.orientation = devicePosition == .front ? .rightBottom : .leftBottom
        case .landscapeRight:
            metadata.orientation = devicePosition == .front ? .topRight : .bottomRight
        case .faceDown, .faceUp, .unknown:
            metadata.orientation = .leftTop
        }
        
        let image = VisionImage(buffer: buffer)
        image.metadata = metadata
        
        barcodeDetector.detect(in: image) { features, error in
            guard error == nil, let features = features, !features.isEmpty else {
                // ...
                return
            }
            
            for barcode in features {
                self.delegate?.BarcodeScannerDidCaptureCode(code: barcode.displayValue ?? "")
            }
            // ...
        }
    }
    
    func stopScanningBarcode(){
        if captureSession?.isRunning ?? false {
            captureSession?.stopRunning()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Barcode Delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        barcodeReader(buffer: sampleBuffer)
        
//        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer!)
//        let comicEffect = CIFilter(name: "CIColorInvert")
//        comicEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
//        let image : UIImage = self.convert(cmage: (comicEffect?.outputImage)!)
//        DispatchQueue.main.async {
//            
//        }
        
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
