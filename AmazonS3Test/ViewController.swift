//
//  ViewController.swift
//  AmazonS3Test
//
//  Created by Raul Uranga on 4/12/16.
//  Copyright © 2016 Raul Uranga. All rights reserved.
//

import UIKit
import MBProgressHUD
import AmazonS3RequestManager
import SwiftyTimer

let kS3Bucket = "YOUR_S3_BUCKET_NAME";
let kS3Region = AmazonS3Region.USWest1;
let kS3AccessKey = "YOUR_S3_ACCESS_KEY";
let kS3Secret = "YOUR_S3_SECRET_KEY";

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var localPath:NSURL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        uploadButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - @IBActions
    
    @IBAction func onTakePicture(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .Camera
        } else {
            imagePicker.sourceType = .PhotoLibrary
        }
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onUploadPicture(sender: AnyObject) {
        
        let uploadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        uploadingNotification.mode = MBProgressHUDMode.Indeterminate
        uploadingNotification.labelText = "Uploading"
        
        let amazonS3Manager = AmazonS3RequestManager(bucket: kS3Bucket,
                                                     region: kS3Region,
                                                     accessKey: kS3AccessKey,
                                                     secret: kS3Secret)
        
        let fileURL: NSURL = NSURL(fileURLWithPath: (self.localPath?.path)!)
        
        amazonS3Manager.putObject(fileURL, destinationPath: self.localPath!.lastPathComponent!).responseS3Data { (response) -> Void in
            
            puts("response complete")
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            uploadingNotification.customView = UIImageView(image: UIImage(named: "Checkmark"));
            uploadingNotification.mode = MBProgressHUDMode.CustomView;
            uploadingNotification.labelText = "Done"
            
            NSTimer.after(2.seconds) {
                uploadingNotification.hide(true)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let fileName = "\(NSUUID().UUIDString).png"
            localPath = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).URLByAppendingPathComponent(fileName)
            
            puts("saving image at: \(localPath!.path!)")
            
            let data = UIImagePNGRepresentation(pickedImage)
            let result = data!.writeToFile(localPath!.path!, atomically: true)
            puts("\(result)")
            
            imageView.contentMode = .ScaleAspectFit
            imageView.image = UIImage(contentsOfFile: localPath!.path!)
            
            uploadButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

