//
//  Copyright © 2025 ObjectBox Ltd. All rights reserved.
//

import XCTest
import ObjectBox
@testable import IntTestiOSXcode16

/// This test ensures the generated code contains code for the defined entity (if not it would fail to compile or the store fail to open or put).
final class IntTestiOSXcode16Tests: XCTestCase {

    private var store: Store?
    private var personBox: Box<Person>?
    
    override func setUpWithError() throws {
        let databaseName = "testdata"
        let appSupport = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(Bundle.main.bundleIdentifier!)
        let directory = appSupport.appendingPathComponent(databaseName)
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        store = try Store(directoryPath: directory.path);
        personBox = store!.box(for: Person.self)
    }
    
    override func tearDownWithError() throws {
        try store?.closeAndDeleteAllFiles()
    }
    
    func testReadWrite() throws {
        let person1 = Person(firstName: "Alice", lastName: "Peterson")
        let person2 = Person(firstName: "Steve", lastName: "Jobs")
        try personBox!.put(person1)
        try personBox!.put(person2)
        let people = try personBox!.all()
        XCTAssert(people.count == 2)
    }
    
}
