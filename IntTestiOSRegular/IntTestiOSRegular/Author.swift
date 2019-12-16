//
//  Copyright © 2019 objectbox. All rights reserved.
//

import Foundation
import ObjectBox

// objectbox:Entity
class Author {
    var id: EntityId<Author> = 0
    var name: String
    
    var notesStandalone: ToMany<Note>
    
    // objectbox: backlink = "author"
    var notes: ToMany<Note>
    var yearOfBirth : UInt16? = nil
    
    
    // An initializer with no parameters is required by ObjectBox
    required init() {
        self.id = 0
        self.name = ""
        self.notes = nil
        self.notesStandalone = nil
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
