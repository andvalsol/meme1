//
//  ViewController.swift
//  ImagePicker
//
//  Created by Andrey Valverde Solera on 2/29/20.
//  Copyright © 2020 Andrey Valverde Solera. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var shareToolbarButton: UIBarButtonItem!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topTextView: UITextField!
    
    @IBOutlet weak var bottomTextView: UITextField!
    
    @IBOutlet weak var cameraPicker: UIBarButtonItem!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    
    // Initialize the UIImagePickerController lazily, since it might not be used
    private lazy var pickerViewController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate for the picker view
        pickerViewController.delegate = self
        
        topTextView.defaultTextAttributes = memeTextAttributes
        topTextView.delegate = self
        topTextView.textAlignment = .center
        
        bottomTextView.defaultTextAttributes = memeTextAttributes
        bottomTextView.textAlignment = .center
        bottomTextView.delegate = self
        
        shareToolbarButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the camera picker if the device doesn't have a camera integrated
        cameraPicker.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Subscribe to keyboard notification
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Unsubscribe the keyboard notification
        unsubscribeKeyboardNotification()
    }
    
    private func generateMemedImage() -> UIImage {
        // Hide the bottom and the top toolbar
        setToolbarsVisibility(shouldBeHidden: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        // Show toolbars
        setToolbarsVisibility(shouldBeHidden: false)

        return memedImage
    }
    
    private func setToolbarsVisibility(shouldBeHidden: Bool) {
        bottomToolbar.isHidden = shouldBeHidden
        topToolbar.isHidden = shouldBeHidden
    }
    
    private func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func unsubscribeKeyboardNotification() {
        // Unsubscribe to all the keyboard notifications
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextView.isFirstResponder && view.frame.origin.y == 0.0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextView.isFirstResponder {
            // Nobe the origin back to 0
            view.frame.origin.y = 0
        }
    }
    
    private func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        return keyboardRectangle.height
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        // Check that there's an original image
        if let originalImage = imagePickerView.image {
            // Get the generated meme image
            let generatedMemeImage = generateMemedImage()
            
            // Create a meme object
            let meme = Meme(topText: topTextView.text!, bottomText: bottomTextView.text!, originalImage: originalImage, memeImage: generatedMemeImage)
            
            let activityViewController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { activity, success, items, error in
                if success {
                    // Save the image
                    UIImageWriteToSavedPhotosAlbum(generatedMemeImage, nil, nil, nil)
                }
            }
        }
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        // Reset all views
        topTextView.text = "TOP TEXT"
        bottomTextView.text = "BOTTOM TEXT"
        imagePickerView.image = nil
        shareToolbarButton.isEnabled = false
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        /**
         This needs a required permission for accesing the devices's camera
         */
        pickerViewController.sourceType = .camera
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        /**
         NOTE:
         When using the UIImagePickerController to bring up the user's photo library, your app doesn't need to request permission explicitly.
         However the permission is listed in the info.plist
         */
        pickerViewController.sourceType = .photoLibrary
        present(pickerViewController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Function called when accesing the camera or the gallery
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = pickedImage
            shareToolbarButton.isEnabled = true
            
        } else {
            shareToolbarButton.isEnabled = true
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)   // removed self
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)   // removed self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Clear text if necessarry
        if topTextView.text == "TOP TEXT" || bottomTextView.text == "BOTTOM TEXT" {
            textField.text = ""
        }
    }
}
