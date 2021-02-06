//
//  NotebookImage.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 5/2/21.
//

import Foundation
import CoreData

public class NotebookImageMO: NSManagedObject {
    
    @discardableResult
    static func createImage(imageData: Data,
                            managedObjectContext: NSManagedObjectContext) -> NotebookImageMO? {
        let notebookImage = NSEntityDescription.insertNewObject(forEntityName: "NotebookImage",
                                                                into: managedObjectContext) as? NotebookImageMO
        
        notebookImage?.image = imageData
        
        return notebookImage
    }
}
