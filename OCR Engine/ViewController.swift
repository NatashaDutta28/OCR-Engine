//
//  ViewController.swift
//  OCR Engine
//
//  Created by Natasha Dutta on 12/10/14.
//  Copyright © 2014 Natasha Dutta. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var textView: UITextView!
    
    
    var activityIndicator:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
    
        let imagePickerActionSheet = UIAlertController(title: "Take/Choose Photo",
            message: nil, preferredStyle: .ActionSheet)
        
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        
        let libraryButton = UIAlertAction(title: "Choose Existing",
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        
        let cancelButton = UIAlertAction(title: "Cancel",
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        
        
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)
    }
    
    
    
    @IBAction func shareText(sender: AnyObject) {
        
        if textView.text.isEmpty {
            displayAlert("Warning", message: "Scan something before sharing!")
        }
        
        
        let activityViewController = UIActivityViewController(activityItems:
            [textView.text], applicationActivities: nil)
        
        
        let excludeActivities = [
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo]
        
        activityViewController.excludedActivityTypes = excludeActivities;
        
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
        return
    }
    
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    func performImageRecognition(image: UIImage) {
        
        let tesseract = G8Tesseract()
        
        tesseract.language = "eng"
        
        tesseract.engineMode = .TesseractCubeCombined
        
        tesseract.pageSegmentationMode = .Auto
        
        tesseract.maximumRecognitionTime = 60.0
        
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        
        textView.text = tesseract.recognizedText
        textView.editable = true
    
        removeActivityIndicator()
    }
}

extension ViewController: UIImagePickerControllerDelegate {
        
        func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
            
            let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
            let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
    
            addActivityIndicator()
            
            dismissViewControllerAnimated(true, completion: {
                self.performImageRecognition(scaledImage)
            })
    }
}

