//
//  DataController.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 29/1/21.
//

import Foundation
import UIKit
import CoreData


class DataController: NSObject {
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @discardableResult
    init(modelName: String, optionalStoreName: String?, completionHandler: (@escaping (NSPersistentContainer?) -> ())) {
        
        if let optionalStoreName = optionalStoreName {
            let managedObjectModel = Self.manageObjectModel(with: modelName)
            self.persistentContainer = NSPersistentContainer(name: optionalStoreName,
                                                             managedObjectModel: managedObjectModel)
            super.init()
            
            persistentContainer.loadPersistentStores { [weak self] (description, error) in
                if let error = error {
                    fatalError("Couldn't load CoreData Stack \(error.localizedDescription)")
                }
                
                completionHandler(self?.persistentContainer)
            }
            
            
        } else {
            
            self.persistentContainer = NSPersistentContainer(name: modelName)
            
            super.init()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.persistentContainer.loadPersistentStores { [weak self] (description, error) in
                    if let error = error {
                        fatalError("Couldn't load CoreData Stack \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(self?.persistentContainer)
                    }
                }
            }
        }
    }
    
    func fetchNotebooks(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NotebookMO]? {
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest) as? [NotebookMO]
        } catch {
            fatalError("Failure to fetch notebooks with context \(fetchRequest), \(error.localizedDescription)")
        }
    }
    
    func fetchNote(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NoteMO]? {
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest) as? [NoteMO]
        } catch {
            fatalError("Failure to fetch note with context \(fetchRequest), \(error.localizedDescription)")
        }
    }
    
    func save() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("=== could not save view context ===")
            fatalError("error: \(error.localizedDescription)")
        }
        
    }
    
    func reset() {
        persistentContainer.viewContext.reset()
    }
    
    func delete() {
        
        let persistentStoreUrl = persistentContainer
            .persistentStoreCoordinator
            .url(for: persistentContainer.persistentStoreCoordinator.persistentStores[0])
        
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: persistentStoreUrl,
                                                                                      ofType: NSSQLiteStoreType,
                                                                                      options: nil)
        } catch {
            fatalError("could not delete test database. \(error.localizedDescription)")
        }
        
    }
    
    static func manageObjectModel(with name: String) -> NSManagedObjectModel {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            fatalError("Error could not find model.")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing managedObjectModel from: \(modelURL)")
        }
        
        return managedObjectModel
    }
    
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = viewContext
        
        privateMOC.perform {
            block(privateMOC)
        }
    }
}

extension DataController {
    
    func addImageNote(image: URL, in note: NoteMO) {
        performInBackground { (prinvateManagedObjectContext) in
            
            guard let imageThumbnail = DownSampler.downsample(imageAt: image),
                  let imageThumbnailData = imageThumbnail.pngData() else {
                return
            }
            
            let managedObjectContext = prinvateManagedObjectContext
            
            let noteID = note.objectID
            let copyNote = managedObjectContext.object(with: noteID) as! NoteMO
            
            let noteImageMO = NoteImageMO.createImage(imageData: imageThumbnailData, managedObjectContext: managedObjectContext)
            noteImageMO?.note = copyNote
            
            do {
                try managedObjectContext.save()
                
            } catch {
                fatalError("failure to save in background.")
            }
        }
        
    }

    
    
    func createNote(notebook: NotebookMO) {
        performInBackground { (prinvateManagedObjectContext) in
            let managedObjectContext = prinvateManagedObjectContext
            
            let notebookID = notebook.objectID
            let copyNotebook = managedObjectContext.object(with: notebookID) as! NotebookMO
            
            NoteMO.createNote(managedObjectContext: managedObjectContext, notebook: copyNotebook, title: "Note3", createdAt: Date(), constents: "content3")
            
            do {
                try managedObjectContext.save()
                
            } catch {
                fatalError("failure to save in background.")
            }
            
        }
    }
    
    
    func loadNotebooksAndNoteIntoViewContext() {
        
        performInBackground { (prinvateManagedObjectContext) in
            let managedObjectContext = prinvateManagedObjectContext
            guard let notebook1 = NotebookMO.createNotebook(createdAt: Date(),
                                                            title: "notebook 1",
                                                            in: managedObjectContext) else { return }
            
            guard let notebook2 = NotebookMO.createNotebook(createdAt: Date(),
                                                            title: "notebook 2",
                                                            in: managedObjectContext) else { return }
            
            let image = UIImage(named: "notebook")
            if let dataNotebookImage = image?.pngData() {
                let notebookImage1 = NotebookImageMO.createImage(imageData: dataNotebookImage, managedObjectContext: managedObjectContext)
                notebook1.notebookImage = notebookImage1
                let notebookImage2 = NotebookImageMO.createImage(imageData: dataNotebookImage, managedObjectContext: managedObjectContext)
                notebook2.notebookImage = notebookImage2
            }
            
            
            NoteMO.createNote(managedObjectContext: managedObjectContext, notebook: notebook1, title: "Note1", createdAt: Date(), constents: "content1")
            NoteMO.createNote(managedObjectContext: managedObjectContext, notebook: notebook1, title: "Note2", createdAt: Date(), constents: "content2")
            NoteMO.createNote(managedObjectContext: managedObjectContext, notebook: notebook2, title: "Note1", createdAt: Date(), constents: "content1")
            NoteMO.createNote(managedObjectContext: managedObjectContext, notebook: notebook2, title: "Note2", createdAt: Date(), constents: "content2")
            
            do {
                try managedObjectContext.save()
                
            } catch {
                fatalError("failure to save in background.")
            }
            
        }
        
    }
}
