//
//  NotebooksTests.swift
//  NotebooksTests
//
//  Created by Félix Luján Albarrán on 29/1/21.
//

import XCTest
import CoreData
@testable import coreDataChecked

class NotebooksTests: XCTestCase {
    
    private let modelName = "NotebookModel"
    private let entity = "Notebook"
    private let optionalStoreName = "NotebookTest"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistentContainer) in
            guard let persistentContainer = persistentContainer else {
                fatalError("couldn't delete test database.")
            }
            
            
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
    }

    func testInit_DataController_Initializes() {
        DataController(modelName: modelName, optionalStoreName: optionalStoreName) { _ in
            XCTAssert(true)
        }
        
    }
    
    func testInit_Notebook() {
        DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistenContainer) in
            guard let persistenContainer = persistenContainer else {
                XCTFail()
                return
            }
            let managedObjectContext = persistenContainer.viewContext
            
            let notebook1 = NotebookMO.createNotebook(createAt: Date(),
                                                     title: "notebook 1",
                                                     in: managedObjectContext)
            
            XCTAssertNotNil(notebook1)
        }
    }
    
    func testFetch_DataController_FechesANotebook() {
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistenContainer) in
            guard persistenContainer != nil else {
                XCTFail()
                return
            }
                    
        }
        
        dataController.loadNotebooksAndNoteIntoViewContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let notebooks = dataController.fetchNotebooks(using: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 2)
    }
    
    func testFilter_DataController_FilterNotebook() {
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistenContainer) in
            guard let managedObjectContext = persistenContainer?.viewContext else {
                XCTFail()
                return
            }
            
            self.insertNotebookInto(managedObjectContext: managedObjectContext)
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "title == %@", "notebook 1")
        
        let notebooks = dataController.fetchNotebooks(using: fetchRequest)
        XCTAssertEqual(notebooks?.count, 1)
    }
    
    func testSave_DataController_SavesInPersistentStore() {
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistenContainer) in
            guard persistenContainer != nil else {
                XCTFail()
                return
            }
        }
        
        dataController.loadNotebooksAndNoteIntoViewContext()
        
        dataController.save()
        
        dataController.reset()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let notebooks = dataController.fetchNotebooks(using: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 2)
    }
    
    func testDelete_DataController_DeletesInPersistentStore() {
        let dataController = DataController(modelName: modelName, optionalStoreName: optionalStoreName) { (persistenContainer) in
            guard persistenContainer != nil else {
                XCTFail()
                return
            }
        }
        
        dataController.loadNotebooksAndNoteIntoViewContext()
        
        dataController.save()
        
        dataController.reset()
        
        dataController.delete()
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let notebooks = dataController.fetchNotebooks(using: fetchRequest)
        
        XCTAssertEqual(notebooks?.count, 0)
        
        
    }
    
    // MARK: - Helper Methods
    func insertNotebookInto(managedObjectContext: NSManagedObjectContext) {
        NotebookMO.createNotebook(createdAt: Date(),
                                  title: "notebook 1",
                                  in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(),
                                  title: "notebook 2",
                                  in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(),
                                  title: "notebook 3",
                                  in: managedObjectContext)
    }
}
