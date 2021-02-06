//
//  NoteImageMO.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 4/2/21.
//

import Foundation

import CoreData

public class NoteImageMO: NSManagedObject {
    @discardableResult
    static func createImage(imageData: Data,
                            managedObjectContext: NSManagedObjectContext) -> NoteImageMO? {
        let noteImage = NSEntityDescription.insertNewObject(forEntityName: "NoteImage",
                                                                into: managedObjectContext) as? NoteImageMO
        
        noteImage?.image = imageData
        noteImage?.createdAt = Date()
        
        return noteImage
    }
}
