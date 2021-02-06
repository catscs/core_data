//
//  Note+CoreDataClass.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 30/1/21.
//
//

import Foundation
import CoreData

public class NoteMO: NSManagedObject {
    
    @discardableResult
    static func createNote(managedObjectContext: NSManagedObjectContext, notebook: NotebookMO, title: String, createdAt: Date, constents: String?) -> NoteMO? {
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note",
                                                       into: managedObjectContext) as? NoteMO
        
        note?.title = title
        note?.createdAt = createdAt
        note?.contents = constents
        note?.notebook = notebook
        
        return note
    }
    
}
