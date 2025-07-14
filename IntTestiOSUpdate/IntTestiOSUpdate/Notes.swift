//
//  Notes.swift
//  IntTestiOSUpdate
//
//  Created by objectbox on 12.09.19.
//  Copyright © 2019-2025 ObjectBox Ltd. All rights reserved.
//

import Foundation
import ObjectBox

class Note: Entity {
    var id: Id = 0
    
    required init() {
        // nothing to do here, ObjectBox calls this
    }
}
