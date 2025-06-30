//
//  Author.swift
//  IntTestiOSRegular
//
//  Created by objectbox on 12.09.19.
//  Copyright © 2019 objectbox. All rights reserved.
//

import Foundation
import ObjectBox

// objectbox:Entity
struct AuthorStruct {
    var id: EntityId<AuthorStruct> = 0
    var name: String
    var notes: ToMany<NoteStruct>
}
