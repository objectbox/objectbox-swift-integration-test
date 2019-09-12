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
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        self.store = try! Store(directoryPath: directory.path);
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try! store?.closeAndDeleteAllFiles()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let noteBox = store?.box(for: Note.self)
        let authorBox = store?.box(for: Author.self)
        
        assert(noteBox!.isEmpty)
        assert(authorBox!.isEmpty)
        
        let note = Note()
        note.text = "Lorem ipsum"
        note.author.target = Author()
        note.author.target?.name = "Arthur"
        
        try! noteBox!.put(note)
        
        assert(noteBox!.count() == 1)
        assert(authorBox!.count() == 1)
        
        assert(1 == authorBox!
            .query{Author.name.contains("a", caseSensitive: false)}
            .link(property: Author.notes){Note.text.contains("Lorem")}
            .build().count());
    }

}
