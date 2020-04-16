//
//  ViewController.swift
//  Pick Image
//
//  Created by Natasha Stopa on 4/9/20.
//  Copyright © 2020 Stopa Inc. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let topPlaceHolderText: String = "TOP"
    let bottomPlaceHolderText: String = "BOTTOM"
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -2.0
    ]
    
    // MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleTextField(topText, topPlaceHolderText)
        styleTextField(bottomText, bottomPlaceHolderText)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareSaveMeme(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        if navigationItem.leftBarButtonItem != nil && imagePickerView.image ==  nil {
            navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Notification subscription and unsubscription
    
    func subscribeToKeyboardNotifications() {
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
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any)  {
        pickFromSource(.photoLibrary)
    }
    
    @IBAction func pickAnImagefromCamera(_ sender: Any) {
        pickFromSource(.camera)
    }
    
    func pickFromSource(_ source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Cancel
    
    @objc func cancel() {
        imagePickerView.image = nil
        topText.text = topPlaceHolderText
        bottomText.text = bottomPlaceHolderText
        navigationItem.leftBarButtonItem?.isEnabled = false
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
    
    
    // MARK: Textfield Behavior and Style
    
    func styleTextField(_ textField: UITextField,_ defaultText: String) {
        textField.text = defaultText
        textField.borderStyle = .none
        textField.delegate = self
        textField.textAlignment = .center
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Clear only if text is default text
        //this would also clear text if the user entered TOP or BOTTOM in the text fields
        if textField.text == topPlaceHolderText || textField.text == bottomPlaceHolderText {
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
        return Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        //Hide toolbar and save button to generate image
        toolBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
       //render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates:  true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //show toolbar and navbar
        toolBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        return memedImage
    }
    
    // MARK: Share and cancel methods
    
    @IBAction func shareSaveMeme(_ sender: Any) {
        let meme = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        controller.completionWithItemsHandler = {[weak self] type, completed, items, error in
            if completed {
              if let meme = self?.generateMeme() {
                //save meme so can be accessed later
                self?.addMemeToArray(meme)
                }
            }
            controller.dismiss(animated: true, completion: nil)
            if (self?.navigationController) != nil {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func addMemeToArray(_ meme : Meme) {
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
    }
}

