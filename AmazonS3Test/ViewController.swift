//
//  ViewController.swift
//  AmazonS3Test
//
//  Created by Raul Uranga on 4/12/16.
//  Copyright © 2016 Raul Uranga. All rights reserved.
//

import UIKit

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
        puts("onUploadPicture")
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

