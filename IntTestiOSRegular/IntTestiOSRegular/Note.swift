//
//  Note.swift
//  IntTestiOSRegular
//
//  Created by objectbox on 12.09.19.
//  Copyright © 2019 objectbox. All rights reserved.
//

import Foundation
import ObjectBox

class Note: Entity {
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
    
    // An initializer with no parameters is required by ObjectBox
    required init() {
        // Nothing to do since we initialize the properties upon declaration here.
        // See `Author` for a different approach
    }
    
    convenience init(title: String, text: String) {
        self.init()
        self.title = title
        self.text = text
    }
}
