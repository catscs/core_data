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
    
    var blockOperations: [BlockOperation] = []
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var note: NoteMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView.collectionViewLayout = layout
        
        titleTextField.text = note?.title
        contentTextView.text = note?.contents
        
        setupNavigationItem()
        loadDataImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if titleTextField.text != note?.title || contentTextView.text != note?.contents {
            if titleTextField.text != "" {
                note?.title = titleTextField.text
            }
            
            if contentTextView.text != "" {
                note?.contents = contentTextView.text
            }
            
        }
        
    }
    
    func loadDataImage() {
        
        guard let dataController = dataController, let note = note else {return}
        
        
        
        let viewContext = dataController.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteImage")
        let noteCreateAtSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [noteCreateAtSortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "note == %@", note)
        
        
        
        self.fetchresultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                 managedObjectContext: viewContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        
        do {
            try self.fetchresultsController?.performFetch()
        } catch {
            print("Error while trying to perform a note fetch")
        }
        
        self.fetchresultsController?.delegate = self
        
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
                if let note = self.note {
                    self.dataController?.addImageNote(image: urlImage, in: note)
                }
            }
        }
    }
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepingCapacity: false)
    }
    
}

extension DetailNoteViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchresultsController?.sections![section].numberOfObjects ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchresultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCell
        
        guard let noteImage = fetchresultsController?.object(at: indexPath) as? NoteImageMO else {
            fatalError("Attempt to configure cell without a manged object")
        }
        if let image = UIImage(data: noteImage.image!){
            cell.configure(image: image)
        }
        
        return cell
    }
    
    
}


// MARK:- NSFetchResultController
extension DetailNoteViewController: NSFetchedResultsControllerDelegate {
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == NSFetchedResultsChangeType.insert {
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertItems(at: [newIndexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadItems(at: [indexPath!])
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteItems(at: [indexPath!])
                    }
                })
            )
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.insertSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.reloadSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collectionView!.deleteSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    
}
