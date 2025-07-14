//
//  Copyright © 2020-2025 ObjectBox Ltd. All rights reserved.
//

import Foundation
import ObjectBox

// objectbox:Entity
class Teacher {
    var id: Id = 0
    var name: String

    // objectbox:backlink = "teachers"
    var students: ToMany<Student> = nil
    
    required init() {
        self.id = 0
        self.name = ""
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// objectbox:Entity
class Student {
    var id: Id = 0
    var name: String

    var teachers: ToMany<Teacher> = nil

    required init() {
        self.id = 0
        self.name = ""
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
