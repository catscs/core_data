//
//  NoteTableViewController.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 4/2/21.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController {
    
    var dataController: DataController?
    var fetchresultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var notebook: NotebookMO?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    public convenience init(dataController: DataController) {
        self.init()
        self.dataController = dataController
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        loadDataNote()
        setupNavigationItem()
    
    }
    
    func setupNavigationItem() {
        let addNoteBarButtonItem = UIBarButtonItem(title: "Add Note", style: .done, target: self, action: #selector(createNote))
        navigationItem.rightBarButtonItem = addNoteBarButtonItem
    }
    
    @objc
    func createNote() {
        guard let notebook = notebook else {return}
        dataController?.createNote(notebook: notebook)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchresultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchresultsController?.sections![section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCellIndentifier", for: indexPath)
        
        guard let note = fetchresultsController?.object(at: indexPath) as? NoteMO else {
            fatalError("Attempt to configure cell without a manged object")
        }
    
        cell.textLabel?.text = note.title
        if let contents = note.contents {
            cell.detailTextLabel?.text = contents
        }

        
        if let noteImage = note.noteImages,
           let imageData = noteImage.allObjects.first as? NoteImageMO,
           let im = imageData.image,
           let image = UIImage(data: im){
            cell.imageView?.image = image
        }
        
        return cell
    }
    
    func loadDataNote(search: String = "") {
        
        guard let dataController = dataController, let notebook = notebook else {return}
        
        title = notebook.title
        
        let viewContext = dataController.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let noteCreateAtSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [noteCreateAtSortDescriptor]
        if search != "" {
            fetchRequest.predicate = NSPredicate(format: "notebook == %@ AND title BEGINSWITH[cd] %@", notebook, search)
        } else {
            fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        }
        
        
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
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier, segueId == "detailNoteIndentify" {
            let destination = segue.destination as! DetailNoteViewController
            let indexPathSelected = tableView.indexPathForSelectedRow!
            let selectedNote = fetchresultsController?.object(at: indexPathSelected) as! NoteMO
            
            destination.note = selectedNote
            destination.dataController = dataController
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailNoteIndentify", sender: nil)
    }

    
}

// MARK:- NSFetchResultController
extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case .move, .update:
                break
            @unknown default: fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default: fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension NoteTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadDataNote()
        } else {
            loadDataNote(search: searchText)
        }
        
    }
}
