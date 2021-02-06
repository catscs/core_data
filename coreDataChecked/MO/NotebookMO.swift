//
//  NotebookMO.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 29/1/21.
//

import Foundation
import CoreData

public class NotebookMO: NSManagedObject {
    
    @discardableResult
    static func createNotebook(createdAt: Date,
                               title: String,
                               in managedObjectContext: NSManagedObjectContext) -> NotebookMO? {
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook",
                                                           into: managedObjectContext) as? NotebookMO
        
        notebook?.createdAt = createdAt
        notebook?.title = title
        return notebook
    }
}
