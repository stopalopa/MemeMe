//
//  ViewController.swift
//  Pick Image
//
//  Created by Natasha Stopa on 4/9/20.
//  Copyright © 2020 Stopa Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -2.0
    ]
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        topText.borderStyle = .none
        bottomText.borderStyle = .none
        self.topText.delegate = self
        self.bottomText.delegate = self
        topText.defaultTextAttributes = memeTextAttributes
        bottomText.defaultTextAttributes = memeTextAttributes
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        if saveButton != nil && imagePickerView.image ==  nil {
            saveButton.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Notification subscription and unsubscription
    
    func subscribeToKeyboardNotifications() {
        print("subscribe")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Show and hide keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomText.isEditing, view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomText.isEditing && view.frame.origin.y != 0 {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Pick Images from Camera or Album
    
    @IBAction func pickAnImagefromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            saveButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any)  {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    
    // MARK: Textfield Behavior
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Clear only if text is default text
        //this would also clear text if the user entered TOP or BOTTOM in the text fields
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    //MARK: Generate Memed Image
    
    func generateMeme() -> Meme {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        return meme
    }
    
    func generateMemedImage() -> UIImage {
        //Hide toolbar and save button to generate image
        toolBar.isHidden = true
        saveButton.isHidden = true
        cancelButton.isHidden = true
       //render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates:  true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //show toolbar and navbar
        toolBar.isHidden = false
        saveButton.isHidden = false
        cancelButton.isHidden = false
        return memedImage
    }
    
    // MARK: Share and cancel methods
    
    @IBAction func shareSaveMeme(_ sender: Any) {
        let meme = generateMeme()
        let controller = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
        
    @IBAction func cancel(_ sender: Any) {
        imagePickerView.image = nil
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        saveButton.isEnabled = false
    }
}

