//
//  SecondViewController.swift
//  poaster
//
//  Created by Vinod Sobale on 12/27/15.
//  Copyright © 2015 Vinod Sobale. All rights reserved.
//

import UIKit
import Mixpanel
import AVFoundation
import MobileCoreServices

enum CameraType {
    case Front
    case Back
}

class SecondViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var QuestionLabel: UILabel!
    
    var picker: UIImagePickerController? = UIImagePickerController()
    var frontCamera = false
    var camera = CameraType.Back
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var selctedImage: UIImage!
    var filterTitleList: [String]!
    var filterNameList: [String]!
    var bIsfromCamera = true
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var cameraSswapButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var filterPicker: UIPickerView!
    @IBOutlet weak var canclButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!

    
    
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    
    let cameraQueue = dispatch_queue_create("com.zero.ALCameraViewController.Queue", DISPATCH_QUEUE_SERIAL);
    
    internal var currentPosition = AVCaptureDevicePosition.Back
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let weekly_notification = prefs.boolForKey("weekly_notification")
        if weekly_notification {
            performSegueWithIdentifier("CameraProfileSegue", sender: self)
            self.prefs.setValue(false, forKey: "weekly_notification")
        } else {
            print("tapped on no notification so false")
        }
        
        
        QuestionLabel.font = UIFont(name: "ProximaNova-Regular", size: 18.0)
        
        self.NextButton.hidden = true
        
        flashButton.setImage(UIImage(named: "FlashOffIcon"), forState: UIControlState.Normal)
        
        canclButton.layer.zPosition = 1;
        
        capturedImage.hidden = true;
        canclButton.hidden = true;
        filterButton.enabled = false;
        // self.okButton.hidden = true
        self.filterTitleList = ["Select Filter","(( No Filter ))" ,"Chrome", "Fade", "Instant", "Mono", "Noir", "Process", "Tonal", "Transfer"]
        
        self.filterNameList = ["No Filter" ,"CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
        
        self.filterPicker.hidden = true
        self.filterPicker.delegate = self
        self.filterPicker.dataSource = self
        
        // Initially showing the toolbar
        self.navigationController?.toolbarHidden = false
        
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        device = self.cameraWithPosition(AVCaptureDevicePosition.Back)
        
        var error: NSError?
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }

        // Changing the case of the Back link
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .Plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("This is an answer \(captureSession.running)")
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        captureSession.stopRunning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = previewView.bounds
        [previewView.bringSubviewToFront(flashButton)];
        [previewView.bringSubviewToFront(cameraSswapButton)];
        [previewView.bringSubviewToFront(canclButton)];
        [previewView.bringSubviewToFront(capturedImage)];
        
        captureSession.startRunning()
    }
    
    @IBAction func PressedTakePhoto(sender: UIButton) {
        Mixpanel.mainInstance().track(event: "Took photo")
        self.capturedImage.hidden = false;
        self.canclButton.hidden = false;
        self.NextButton.hidden = false
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider!, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.selctedImage = image
                    self.capturedImage.image = self.selctedImage
                    self.filterButton.enabled = true
                    do {
                        try self.device.lockForConfiguration()
                        // self.device.torchMode = AVCaptureTorchMode.Off
                        self.device.unlockForConfiguration()
                    }catch {
                        print(error)
                    }
                }
            })
        }
    }
    
    @IBAction func PressedCancelButton(sender: UIButton) {
        captureSession!.startRunning()
        capturedImage.hidden = true;
        canclButton.hidden = true;
        capturedImage.image = nil;
        filterButton.enabled = false;
        self.NextButton.hidden = true
        self.filterPicker.hidden = true
    }
    
    @IBAction func toggleFlash(sender: UIButton) {
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                    flashButton.setImage(UIImage(named: "FlashOffIcon"), forState: UIControlState.Normal)
                } else {
                    do {
                        flashButton.setImage(UIImage(named: "FlashOnIcon"), forState: UIControlState.Normal)
                        try device.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func changeCamera(sender: UIButton) {
        Mixpanel.mainInstance().track(event: "Changed camera")
        frontCamera = !frontCamera
        
        if captureSession != nil && input != nil {
            //captureSession.beginConfiguration()
            captureSession.removeInput(input)
            
            if input.device.position == AVCaptureDevicePosition.Back {
                currentPosition = AVCaptureDevicePosition.Front
                device = cameraWithPosition(currentPosition)
                flashButton.hidden = true;
            } else {
                flashButton.hidden = false;
                currentPosition = AVCaptureDevicePosition.Back
                device = cameraWithPosition(currentPosition)
            }
            
            let error:NSErrorPointer = nil
            // let error = NSErrorPointer()
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch let error1 as NSError {
                error.memory = error1
                input = nil
            }
            
            if error == nil && captureSession!.canAddInput(input) {
                captureSession!.addInput(input)
            }
        }
    }
    
    
    @IBAction func SendImageToMakePoast(sender: UIButton) {
        let MakePoastVC = self.storyboard?.instantiateViewControllerWithIdentifier("MakePoastView") as! MakePoastViewController
        MakePoastVC.receivedImage = self.capturedImage.image
        self.navigationController!.pushViewController(MakePoastVC, animated: true)
    }
    
    
    @IBAction func openCameraRoll(sender: UIButton) {
        Mixpanel.mainInstance().track(event: "Opened cameraroll")
        openGallary()
    }
    
    @IBAction func applyFilterOnImage(sender: UIButton) {
        self.filterPicker.hidden = false
        self.filterPicker.selectRow(0, inComponent: 0, animated: true)
        Mixpanel.mainInstance().track(event: "Applied filter")
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if(device.position == position){
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    private func applyFilter(selectedFilterIndex filterIndex: Int) {
        if filterIndex == 0 || filterIndex == 1 {
            self.capturedImage.image = self.selctedImage
            return
        }
        let sourceImage = CIImage(image: self.capturedImage.image!)
        let myFilter = CIFilter(name: self.filterNameList[filterIndex - 1])
        myFilter!.setValue(sourceImage, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        let outputCGImage = context.createCGImage(myFilter!.outputImage!, fromRect:myFilter!.outputImage!.extent )
        
        if bIsfromCamera{
            let newImage = UIImage(CGImage:outputCGImage!, scale: self.selctedImage.scale, orientation: self.selctedImage.imageOrientation)
            self.capturedImage.image = newImage
        }else{
            let newImage = UIImage(CGImage: outputCGImage!, scale: self.selctedImage.scale, orientation: self.selctedImage.imageOrientation)
            self.capturedImage.image = newImage
        }
    }
    
    
    func openGallary() {
        picker!.allowsEditing = false
        picker!.delegate = self;
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(picker!, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let chooseImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.selctedImage = chooseImage
        capturedImage.image = self.selctedImage
        dismissViewControllerAnimated(true, completion: nil)
        self.filterPicker.hidden = true
        self.capturedImage.hidden = false
        self.filterButton.enabled = true
        self.canclButton.hidden = false
        self.NextButton.hidden = false
        bIsfromCamera = false
        captureSession!.stopRunning()
    }
    
    func openImageView(){
        self.capturedImage.hidden = false;
        self.canclButton.hidden = false;
        captureSession!.stopRunning()
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.filterTitleList.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.filterTitleList[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.filterPicker.hidden = true
        self.applyFilter(selectedFilterIndex: row)
    }
    
    private func saveImageToPhotoGallery(){
        UIImageWriteToSavedPhotosAlbum(self.capturedImage.image!, nil, nil, nil)
        // self.okButton.hidden = true
        captureSession!.startRunning()
        capturedImage.hidden = true;
        canclButton.hidden = true;
        capturedImage.image = nil;
        filterButton.enabled = false;
        self.filterPicker.hidden = true
    }
}
