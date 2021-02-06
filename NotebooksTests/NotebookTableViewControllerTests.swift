//
//  NotebookTableViewControllerTests.swift
//  NotebooksTests
//
//  Created by Félix Luján Albarrán on 30/1/21.
//

import XCTest
import CoreData
@testable import coreDataChecked

class NotebookTableViewControllerTests: XCTestCase {

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

    func testFetchResultsController_FetchesNotebooksInViewContext_InMemory() {
        let dataController = DataController(modelName: modelName,
                                            optionalStoreName: optionalStoreName) { (pres) in }
        
        dataController.loadNotebooksAndNoteIntoViewContext()
        
        let notebookViewController = NotebookTableViewController(dataController: dataController)
        
        notebookViewController.loadViewIfNeeded()
        
        let foundNotebooks = notebookViewController.fetchresultsController?.fetchedObjects?.count
        
        XCTAssertEqual(foundNotebooks, 2)
        
    }
    
    func testFetchResultsController_FetchesNotebooksInViewContext_InStore() {
        let dataController = DataController(modelName: modelName,
                                            optionalStoreName: optionalStoreName) { (pres) in }
        
        dataController.loadNotebooksAndNoteIntoViewContext()
        
        dataController.save()
        
        dataController.reset()
        
        let notebookViewController = NotebookTableViewController(dataController: dataController)
        
        notebookViewController.loadViewIfNeeded()
        
        let foundNotebooks = notebookViewController.fetchresultsController?.fetchedObjects?.count
        
        XCTAssertEqual(foundNotebooks, 2)
        
    }

}
