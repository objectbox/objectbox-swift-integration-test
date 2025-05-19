import ObjectBox

// objectbox: entity
class Person {
    var id: Id = 0
    var firstName: String = ""
    var lastName: String = ""
    
    init() {} // Used by ObjectBox
    
    init(id: Id = 0, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
