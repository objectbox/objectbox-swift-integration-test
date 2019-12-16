//  Copyright © 2019 objectbox. All rights reserved.

import XCTest
@testable import IntTestiOSRegular
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
        XCTAssertEqual(try query.findUnique().text, "fertig")
        try query.setParameter(Note.done, to: true)
        try query.setParameter("2nd bool", to: true)
        XCTAssertEqual(try query.findUnique().text, "fertig")

        try query.setParameter(Note.done, to: false)
        try query.setParameter("2nd bool", to: false)
        XCTAssertEqual(try query.count(), 1)
        XCTAssertEqual(try query.findUnique().text, "todo")
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
        XCTAssertEqual(try query.findUnique().text, "first")
        try query.setParameter(Note.upvotes, to: 10)
        try query.setParameter("2nd", to: 13)
        XCTAssertEqual(try query.findUnique().text, "first")

        try query.setParameter(Note.upvotes, to: 20)
        try query.setParameter("2nd", to: 42)
        XCTAssertEqual(try query.count(), 1)
        XCTAssertEqual(try query.findUnique().text, "second")
    }
    
}
