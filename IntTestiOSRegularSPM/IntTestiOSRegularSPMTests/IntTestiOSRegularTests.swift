//  Copyright © 2019 objectbox. All rights reserved.

import XCTest
@testable import IntTestiOSRegularSPM
import ObjectBox

class IntTestiOSRegularTests: XCTestCase {
    static var printedVersion = false

    var store : Store?
    var noteBox : Box<Note>?
    var noteStructBox : Box<NoteStruct>?
    var authorBox : Box<Author>?
    var authorStructBox : Box<AuthorStruct>?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let databaseName = "testdata"
        let appSupport = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(Bundle.main.bundleIdentifier!)
        let directory = appSupport.appendingPathComponent(databaseName)
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        store = try! Store(directoryPath: directory.path);
        noteBox = store?.box(for: Note.self)
        authorBox = store?.box(for: Author.self)
        noteStructBox = store?.box(for: NoteStruct.self)
        authorStructBox = store?.box(for: AuthorStruct.self)

        if(!IntTestiOSRegularTests.printedVersion) {
            print(Store.versionFullInfo)
            IntTestiOSRegularTests.printedVersion=true
        }

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try! store?.closeAndDeleteAllFiles()
    }

    func testClasses() throws {
        XCTAssert(try noteBox!.isEmpty())
        XCTAssert(try authorBox!.isEmpty())
        
        let note = Note()
        note.text = "Lorem ipsum"
        note.author.target = Author()
        note.author.target?.name = "Arthur"
        
        try! noteBox!.put(note)
        
        XCTAssertEqual(try noteBox!.count(), 1)
        XCTAssertEqual(try authorBox!.count(), 1)
        
        XCTAssertEqual(1, try authorBox!
            .query{Author.name.contains("a", caseSensitive: false)}
            .link(Author.notes){Note.text.contains("Lorem")}
            .build().count())
    }
    
    func testClassesToManyStandalone() throws {
        // there's a ToMany relation in AuthorStruct for NoteStruct
        
        let note = Note(title: "Title", text: "Lorem ipsum")
        note.id = try! noteBox!.put(note) // at v1.0.0-rc6, requires an explicit put
        
        let author = Author( name: "Arthur")
        try! authorBox!.put(author)

        author.notesStandalone.append(note)
        try! author.notesStandalone.applyToDb()

        XCTAssertEqual(try noteBox!.count(), 1)
        XCTAssertEqual(try authorBox!.count(), 1)
        
        XCTAssertEqual(1, try authorBox!
            .query{Author.name.contains("a", caseSensitive: false)}
            .link(Author.notesStandalone){Note.text.contains("Lorem")}
            .build().count())
    }
    
    func testStructToClassLink() throws {
        let author = Author(name: "Arthur")
        let relation = ToOne<Author>(author)
        
        let note = NoteStruct(id: 0, title: "Title", text: "Lorem ipsum", creationDate: Date(), modificationDate: Date(), author: relation)
        try! noteStructBox!.put(note)
        
        XCTAssertEqual(try noteStructBox!.count(), 1)
        XCTAssertEqual(try authorBox!.count(), 1)
        
        XCTAssertEqual(1, try noteStructBox!
            .query{NoteStruct.text.contains("Lorem")}
            .link(NoteStruct.author){Author.name.contains("a", caseSensitive: false)}
            .build().count())
    }
    
    func testStructsToManyStandalone() throws {
        // there's a ToMany relation in AuthorStruct for NoteStruct

        var note = NoteStruct(id: 0, title: "Title", text: "Lorem ipsum", creationDate: Date(), modificationDate: Date(), author: ToOne<Author>(nil))
        note.id = try! noteStructBox!.put(note) // at v1.0.0-rc6, requires an explicit put
        
        let notes = ToMany<NoteStruct>([note])
        let author = AuthorStruct(id: EntityId<AuthorStruct>(0), name: "Arthur", notes: notes)
        try! authorStructBox!.put(author)
        
        XCTAssertEqual(try noteStructBox!.count(), 1)
        XCTAssertEqual(try authorStructBox!.count(), 1)
        
        // TODO at v1.0.0-rc7, this doesn't work
//        XCTAssertEqual(1, authorBox!
//            .query{AuthorStruct.name.contains("a", caseSensitive: false)}
//            .link(AuthorStruct.notes){NoteStruct.text.contains("Lorem")}
//            .build().count())
    }
    
    func testQueryBool() throws { // Since 1.2
        let note = Note()
        note.text = "fertig"
        note.done = true
        
        let note2 = Note()
        note2.text = "todo"
        note2.done = false
        
        try! noteBox!.put([note, note2])
        XCTAssertEqual(try noteBox!.count(), 2)
        
        let query = try noteBox!.query{Note.done == true && "2nd bool" .= Note.done.isEqual(to: true)}.build()
        XCTAssertEqual(try query.findUnique()!.text, "fertig")
        query.setParameter(Note.done, to: true)
        query.setParameter("2nd bool", to: true)
        XCTAssertEqual(try query.findUnique()!.text, "fertig")

        query.setParameter(Note.done, to: false)
        query.setParameter("2nd bool", to: false)
        XCTAssertEqual(try query.count(), 1)
        XCTAssertEqual(try query.findUnique()!.text, "todo")
    }
    
    func testQueryUnsigned() throws { // Since 1.2
        let note = Note()
        note.text = "first"
        note.upvotes = 13
        
        let note2 = Note()
        note2.text = "second"
        note2.upvotes = 42
        
        try! noteBox!.put([note, note2])
        XCTAssertEqual(try noteBox!.count(), 2)
        
        let query = try noteBox!.query{Note.upvotes > 10 && "2nd" .= Note.upvotes.isEqual(to: 13)}.build()
        XCTAssertEqual(try query.findUnique()!.text, "first")
        query.setParameter(Note.upvotes, to: 10)
        query.setParameter("2nd", to: 13)
        XCTAssertEqual(try query.findUnique()!.text, "first")

        query.setParameter(Note.upvotes, to: 20)
        query.setParameter("2nd", to: 42)
        XCTAssertEqual(try query.count(), 1)
        XCTAssertEqual(try query.findUnique()!.text, "second")
    }

    func testQueryUnsignedOptional() throws { // Since 1.2
        let author = Author()
        author.name = "Alice"
        author.yearOfBirth = 1903

        let author2 = Author()
        author2.name = "Bob"
        author2.yearOfBirth = 2001

        let author3 = Author()
        author3.name = "Cesar"
        author3.yearOfBirth = nil

        try! authorBox!.put([author, author2, author3])
        XCTAssertEqual(try authorBox!.count(), 3)

        let query = try authorBox!.query{Author.yearOfBirth > 1900 && "2nd" .= Author.yearOfBirth < 2020 }.build()
        XCTAssertEqual(try query.count(), 2)

        query.setParameter(Author.yearOfBirth, to: 2000)
        XCTAssertEqual(try query.count(), 1)
        XCTAssertEqual(try query.findUnique()!.name, "Bob")

        query.setParameter("2nd", to: 1950)
        XCTAssertEqual(try query.count(), 0)

        let queryNil = try authorBox!.query{ Author.yearOfBirth.isNil() }.build()
        XCTAssertEqual(try queryNil.findUnique()!.name, "Cesar")
    }

    func testManyToMany() throws {
        let teacher1 = Teacher(name: "Yoda")
        let teacher2 = Teacher(name: "Dumbledore")
        
        let student1 = Student(name: "Alice")
        let student2 = Student(name: "Bob")
        let student3 = Student(name: "Claire")

        let teacherBox = store!.box(for: Teacher.self)
        try teacherBox.put([teacher1, teacher2])
        
        let studentBox = store!.box(for: Student.self)
        try studentBox.put([student1, student2, student3])
        
        teacher1.students.append(student1)
        teacher1.students.append(student3)
        try teacher1.students.applyToDb()
        
        let claire = try studentBox.get(student3.id)!
        XCTAssertEqual(claire.teachers[0].id, teacher1.id)
        //claire.teachers.replace([])
        claire.teachers.remove(at: 0)
        try claire.teachers.applyToDb()
        
        teacher1.students.reset()
        XCTAssertEqual(teacher1.students.count, 1)
    }

    // TODO enable once we have SyncClient protocol in all tested versions (available since 1.4.0) 
//    func testDrySync() throws {
//        print("Sync available: ", Sync.isAvailable())
//        if Sync.isAvailable() {
//            let client = try Sync.makeClient(store: store!, urlString: "ws://127.0.0.1:9999")
//            try client.setCredentials(SyncCredentials.makeUnchecked())
//            XCTAssertEqual(client.getState(), SyncState.created)
//            try client.start()
//            XCTAssertEqual(client.getState(), SyncState.started)
//            try client.stop()
//            XCTAssertEqual(client.getState(), SyncState.stopped)
//            client.close()
//            XCTAssertEqual(client.getState(), SyncState.dead)
//        }
//    }

}
