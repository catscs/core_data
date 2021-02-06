//
//  Note+CoreDataProperties.swift
//  coreDataChecked
//
//  Created by Félix Luján Albarrán on 30/1/21.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var notebook: NotebookMO?

}

extension Note : Identifiable {

}
