//
//  NotebookTableViewController.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 30/1/21.
//

import UIKit
import CoreData

class NotebookTableViewController: UITableViewController {

    var dataController: DataController?
    var fetchresultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
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
        initializeFetchReultsController()
       
        let loadDataBarButtonItem = UIBarButtonItem(title: "Load Data", style: .done, target: self, action: #selector(loadData))
        navigationItem.rightBarButtonItem = loadDataBarButtonItem
        
        let deleteBarButtonItem = UIBarButtonItem(title: "Delete Data", style: .done, target: self, action: #selector(deleteData))
        navigationItem.leftBarButtonItem = deleteBarButtonItem
    }
    
    @objc
    func loadData(){
        dataController?.loadNotebooksAndNoteIntoViewContext()
    }
    
    @objc
    func deleteData() {
        dataController?.save()
        dataController?.delete()
        dataController?.reset()
        initializeFetchReultsController()
        tableView.reloadData()
    }
    
    func initializeFetchReultsController() {
        guard let dataController = dataController else {return}
        
        let viewContext = dataController.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        let notebookSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [notebookSortDescriptor]
    
        
        self.fetchresultsController = NSFetchedResultsController(fetchRequest: request,
                                   managedObjectContext: viewContext,
                                   sectionNameKeyPath: nil,
                                   cacheName: nil)
        
        do {
            try self.fetchresultsController?.performFetch()
        } catch {
            print("Error while trying to perform a notebook fetch")
        }
        
        self.fetchresultsController?.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchresultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchresultsController?.sections![section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notebookCell", for: indexPath)
        
        guard let notebook = fetchresultsController?.object(at: indexPath) as? NotebookMO else {
            fatalError("Attempt to configure cell without a manged object")
        }
    
        cell.textLabel?.text = notebook.title
        if let createdAt = notebook.createdAt {
            cell.detailTextLabel?.text = HelperDateFormatter.textFrom(date: createdAt)
        }
        
        
        if let notebookImage = notebook.notebookImage,
           let imageData = notebookImage.image,
           let image = UIImage(data: imageData){
            cell.imageView?.image = image
        }
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier, segueId == "noteIdentifier" {
            let destination = segue.destination as! NoteTableViewController
            let indexPathSelected = tableView.indexPathForSelectedRow!
            let selectedNotebook = fetchresultsController?.object(at: indexPathSelected) as! NotebookMO
            
            destination.notebook = selectedNotebook
            destination.dataController = dataController
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "noteIdentifier", sender: nil)
    }

}

// MARK:- NSFetchResultController
extension NotebookTableViewController: NSFetchedResultsControllerDelegate {
    
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
