//
//  DetailNoteViewController.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 5/2/21.
//

import UIKit
import CoreData

class DetailNoteViewController: UIViewController,  UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var dataController: DataController?
    var fetchresultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    var note: NoteMO?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.text = note?.title
        contentTextView.text = note?.contents
       
        
        setupNavigationItem()
    }
    
    func setupNavigationItem() {
        let addImageBarButtomItem = UIBarButtonItem(title: "Add image", style: .done, target: self, action: #selector(createAndPresentImagePicker))
        navigationItem.rightBarButtonItem = addImageBarButtomItem
    }
    
    @objc
    func createAndPresentImagePicker() {
        let picker  = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary),
            let availabletypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = availabletypes
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            if let urlImage = info[.imageURL] as? URL {
                
                // data controller para poder crear nuestra nota y photograph asociada.
                if let note = self.note {
                    self.dataController?.addImageNote(image: urlImage, in: note)
                }
            }
        }
    }
  

}
