//
//  Notes.swift
//  IntTestiOSUpdate
//
//  Created by objectbox on 12.09.19.
//  Copyright © 2019 objectbox. All rights reserved.
//

import Foundation
import ObjectBox

class Note: Entity {
    var id: Id<Note> = 0
    
    required init() {
        // nothing to do here, ObjectBox calls this
    }
}
