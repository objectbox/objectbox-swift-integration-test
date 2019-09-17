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

    func testClasses() {
        let noteBox = store?.box(for: Note.self)
        let authorBox = store?.box(for: Author.self)
        
        XCTAssert(noteBox!.isEmpty())
        XCTAssert(authorBox!.isEmpty())
        
        let note = Note()
        note.text = "Lorem ipsum"
        note.author.target = Author()
        note.author.target?.name = "Arthur"
        
        try! noteBox!.put(note)
        
        XCTAssertEqual(noteBox!.count(), 1)
        XCTAssertEqual(authorBox!.count(), 1)
        
        XCTAssertEqual(1, authorBox!
            .query{Author.name.contains("a", caseSensitive: false)}
            .link(property: Author.notes){Note.text.contains("Lorem")}
            .build().count())
    }
    
    func testStructToClassLink() {
        // there's a link from NoteStruct to Author
        let noteBox = store?.box(for: NoteStruct.self)
        let authorBox = store?.box(for: Author.self)
        
        XCTAssert(noteBox!.isEmpty())
        XCTAssert(authorBox!.isEmpty())
        
        let author = Author(name: "Arthur");
        let relation = ToOne<Author>(author);
        
        let note = NoteStruct(id: 0, title: "Title", text: "Lorem ipsum", creationDate: Date(), modificationDate: Date(), author: relation)
        
        try! noteBox!.put(note)
        
        XCTAssertEqual(noteBox!.count(), 1)
        XCTAssertEqual(authorBox!.count(), 1)
        
        XCTAssertEqual(1, noteBox!
            .query{NoteStruct.text.contains("Lorem")}
            .link(property: NoteStruct.author){Author.name.contains("a", caseSensitive: false)}
            .build().count())
    }
    
    func testStructsToManyStandalone() {
        // there's a ToMany relation in AuthorStruct for NoteStruct
        let noteBox = store?.box(for: NoteStruct.self)
        let authorBox = store?.box(for: AuthorStruct.self)
        
        XCTAssert(noteBox!.isEmpty())
        XCTAssert(authorBox!.isEmpty())
        
        var note = NoteStruct(id: 0, title: "Title", text: "Lorem ipsum", creationDate: Date(), modificationDate: Date(), author: ToOne<Author>(nil));
        note.id = try! noteBox!.put(note); // at v1.0, requires an explicit put
        
        let notes = ToMany<NoteStruct, AuthorStruct>([note]);
        let author = AuthorStruct(id: EntityId<AuthorStruct>(0), name: "Arthur", notes: notes);

        try! authorBox!.put(author)
        
        XCTAssertEqual(noteBox!.count(), 1)
        XCTAssertEqual(authorBox!.count(), 1)
        
        XCTAssertEqual(1, authorBox!
            .query{AuthorStruct.name.contains("a", caseSensitive: false)}
            .link(property: AuthorStruct.notes){NoteStruct.text.contains("Lorem")}
            .build().count())
    }
}
