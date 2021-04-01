//
//  UploadViewController.swift
//  InstaCloneFirebase
//
//  Created by Semih Özsoy on 14.03.2021.
//

import UIKit
import Firebase

class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageUpload: UIImageView!
    
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet var uploadButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageUpload.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageUpload.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func chooseImage(){
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageUpload.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(titleInput: String, messageInput: String ){
    
        let alert = UIAlertController(title: title, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
        
        
    }

    @IBAction func actionButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = imageUpload.image?.jpegData(compressionQuality: 0.5){
            
            // burdaki işlem uuid olan image ın storage a farklı olarak kaydedilebilmesi için gerekli
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    
                    self.makeAlert(titleInput: "Error!", messageInput:error?.localizedDescription ?? "Error")
                    
                } else {
                    
                    imageReference.downloadURL { (url, error) in
                        
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            
                            // DATABASE
                            
                            let firestoreDatabase = Firestore.firestore()
                            
                            var firestoreReference : DocumentReference? = nil
                            
                            let firestorePost = ["imageUrl" : imageUrl!, "postedBy": Auth.auth().currentUser!.email!,"postComment": self.commentText.text!, "date": FieldValue.serverTimestamp(), "likes": 0  ] as [String : Any]
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil {
                                    
                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                } else{
                                    
                                    self.imageUpload.image = UIImage(named:"select.png")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                    
                                }
                            })
                            
                            
                            
                        }
                    }
                }
            }
        }
        
        
        
    }
    
    
    
    

}
