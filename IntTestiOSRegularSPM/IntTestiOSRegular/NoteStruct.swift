//
//  Note.swift
//  IntTestiOSRegular
//
//  Created by objectbox on 12.09.19.
//  Copyright © 2019 objectbox. All rights reserved.
//

import Foundation
import ObjectBox

// objectbox:Entity
struct NoteStruct {
    var id: Id = 0 
    var title: String = "" {
        didSet {
            modificationDate = Date()
        }
    }
    var text: String = "" {
        didSet {
            modificationDate = Date()
        }
    }
    var creationDate: Date? = Date()
    var modificationDate: Date?
    var author: ToOne<Author> = nil
}
