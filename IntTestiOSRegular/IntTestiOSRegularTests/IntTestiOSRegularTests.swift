//
//  IntTestiOSRegularTests.swift
//  IntTestiOSRegularTests
//
//  Created by objectbox on 12.09.19.
//  Copyright © 2019 objectbox. All rights reserved.
//

import XCTest
@testable import IntTestiOSRegular
import ObjectBox

class IntTestiOSRegularTests: XCTestCase {
    var store : Store?;
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let databaseName = "testdata"
        let appSupport = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(Bundle.main.bundleIdentifier!)
        let directory = appSupport.appendingPathComponent(databaseName)
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        self.store = try! Store(directoryPath: directory.path);
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try! store?.closeAndDeleteAllFiles()
    }

    func testClasses() throws {
        let noteBox = store?.box(for: Note.self)
        let authorBox = store?.box(for: Author.self)
        
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
        let noteBox = store?.box(for: Note.self)
        let authorBox = store?.box(for: Author.self)
        
        XCTAssert(try noteBox!.isEmpty())
        XCTAssert(try authorBox!.isEmpty())
        
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
        // there's a link from NoteStruct to Author
        let noteBox = store?.box(for: NoteStruct.self)
        let authorBox = store?.box(for: Author.self)
        
        XCTAssert(try noteBox!.isEmpty())
        XCTAssert(try authorBox!.isEmpty())
        
        let author = Author(name: "Arthur")
        let relation = ToOne<Author>(author)
        
        let note = NoteStruct(id: 0, title: "Title", text: "Lorem ipsum", creationDate: Date(), modificationDate: Date(), author: relation)
        
        try! noteBox!.put(note)
        
        XCTAssertEqual(try noteBox!.count(), 1)
        XCTAssertEqual(try authorBox!.count(), 1)
        
        XCTAssertEqual(1, try noteBox!
            .query{NoteStruct.text.contains("Lorem")}
            .link(NoteStruct.author){Author.name.contains("a", caseSensitive: false)}
            .build().count())
    }
    
    func testStructsToManyStandalone() throws {
        // there's a ToMany relation in AuthorStruct for NoteStruct
        let noteBox = store?.box(for: NoteStruct.self)
        let authorBox = store?.box(for: AuthorStruct.self)
        
        XCTAssert(try noteBox!.isEmpty())
        XCTAssert(try authorBox!.isEmpty())
        
        var note = NoteStruct(id: 0, title: "Title", text: "Lorem ipsum", creationDate: Date(), modificationDate: Date(), author: ToOne<Author>(nil))
        note.id = try! noteBox!.put(note) // at v1.0.0-rc6, requires an explicit put
        
        let notes = ToMany<NoteStruct>([note])
        let author = AuthorStruct(id: EntityId<AuthorStruct>(0), name: "Arthur", notes: notes)

        try! authorBox!.put(author)
        
        XCTAssertEqual(try noteBox!.count(), 1)
        XCTAssertEqual(try authorBox!.count(), 1)
        
        // TODO at v1.0.0-rc7, this doesn't work
//        XCTAssertEqual(1, authorBox!
//            .query{AuthorStruct.name.contains("a", caseSensitive: false)}
//            .link(AuthorStruct.notes){NoteStruct.text.contains("Lorem")}
//            .build().count())
    }
}
