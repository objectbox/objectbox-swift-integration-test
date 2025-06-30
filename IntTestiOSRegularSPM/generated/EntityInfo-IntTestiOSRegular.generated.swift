// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata

extension Author: ObjectBox.Entity {}
extension AuthorStruct: ObjectBox.Entity {}
extension NoteStruct: ObjectBox.Entity {}
extension Student: ObjectBox.Entity {}
extension Teacher: ObjectBox.Entity {}

extension Author: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Author

    internal var _id: EntityId<Author> {
        return EntityId<Author>(self.id.value)
    }
}

extension Author: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = AuthorBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Author", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Author.self, id: 1, uid: 8437793116920511488)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 9029561746337056768)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 5065223589723312128)
        try entityBuilder.addProperty(name: "yearOfBirth", type: PropertyType.short, id: 3, uid: 2504474839991293952)
        try entityBuilder.addToManyRelation(id: 1, uid: 1465037069146083072,
                                            targetId: 3, targetUid: 6621987164459613696)

        try entityBuilder.lastProperty(id: 3, uid: 2504474839991293952)
    }
}

extension Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.id == myId }
    internal static var id: Property<Author, EntityId<Author>, EntityId<Author>> { return Property<Author, EntityId<Author>, EntityId<Author>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.name.startsWith("X") }
    internal static var name: Property<Author, String, Void> { return Property<Author, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.yearOfBirth > 1234 }
    internal static var yearOfBirth: Property<Author, UInt16?, Void> { return Property<Author, UInt16?, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Use `Author.notesStandalone` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notesStandalone: ToManyProperty<Note> { return ToManyProperty(.relationId(1)) }

    /// Use `Author.notes` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<Note> { return ToManyProperty(.valuePropertyId(6)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Author, EntityId<Author>, EntityId<Author>> { return Property<Author, EntityId<Author>, EntityId<Author>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Author, String, Void> { return Property<Author, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .yearOfBirth > 1234 }

    internal static var yearOfBirth: Property<Author, UInt16?, Void> { return Property<Author, UInt16?, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Use `.notesStandalone` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notesStandalone: ToManyProperty<Note> { return ToManyProperty(.relationId(1)) }

    /// Use `.notes` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<Note> { return ToManyProperty(.valuePropertyId(6)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Author.EntityBindingType`.
internal class AuthorBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Author
    internal typealias IdType = EntityId<Author>

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.yearOfBirth, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            let notesStandalone = ToMany<Note>.relation(
                sourceId: EntityId<Author>(id.value),
                targetBox: store.box(for: ToMany<Note>.ReferencedType.self),
                relationId: 1)
            if !entity.notesStandalone.isEmpty {
                notesStandalone.replace(entity.notesStandalone)
            }
            entity.notesStandalone = notesStandalone
            let notes = ToMany<Note>.backlink(
                sourceBox: store.box(for: ToMany<Note>.ReferencedType.self),
                sourceProperty: ToMany<Note>.ReferencedType.author,
                targetId: EntityId<Author>(id.value))
            if !entity.notes.isEmpty {
                notes.replace(entity.notes)
            }
            entity.notes = notes
            try entity.notesStandalone.applyToDb()
            try entity.notes.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Author()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)
        entity.yearOfBirth = entityReader.read(at: 2 + 2 * 3)

        entity.notesStandalone = ToMany<Note>.relation(
            sourceId: EntityId<Author>(entity.id.value),
            targetBox: store.box(for: ToMany<Note>.ReferencedType.self),
            relationId: 1)
        entity.notes = ToMany<Note>.backlink(
            sourceBox: store.box(for: ToMany<Note>.ReferencedType.self),
            sourceProperty: ToMany<Note>.ReferencedType.author,
            targetId: EntityId<Author>(entity.id.value))
        return entity
    }
}



extension AuthorStruct: ObjectBox.__EntityRelatable {
    internal typealias EntityType = AuthorStruct

    internal var _id: EntityId<AuthorStruct> {
        return EntityId<AuthorStruct>(self.id.value)
    }
}

extension AuthorStruct: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = AuthorStructBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "AuthorStruct", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: AuthorStruct.self, id: 2, uid: 9044639918046123008)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 1160801756948174080)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 6748645549008691456)
        try entityBuilder.addToManyRelation(id: 2, uid: 2723651020904101376,
                                            targetId: 4, targetUid: 1207223334387100416)

        try entityBuilder.lastProperty(id: 2, uid: 6748645549008691456)
    }
}

extension AuthorStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AuthorStruct.id == myId }
    internal static var id: Property<AuthorStruct, EntityId<AuthorStruct>, EntityId<AuthorStruct>> { return Property<AuthorStruct, EntityId<AuthorStruct>, EntityId<AuthorStruct>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AuthorStruct.name.startsWith("X") }
    internal static var name: Property<AuthorStruct, String, Void> { return Property<AuthorStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `AuthorStruct.notes` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<NoteStruct> { return ToManyProperty(.relationId(2)) }


    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == AuthorStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<AuthorStruct, EntityId<AuthorStruct>, EntityId<AuthorStruct>> { return Property<AuthorStruct, EntityId<AuthorStruct>, EntityId<AuthorStruct>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<AuthorStruct, String, Void> { return Property<AuthorStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.notes` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<NoteStruct> { return ToManyProperty(.relationId(2)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `AuthorStruct.EntityBindingType`.
internal class AuthorStructBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = AuthorStruct
    internal typealias IdType = EntityId<AuthorStruct>

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setStructEntityId(of entity: inout EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entityId: EntityId<AuthorStruct> = entityReader.read(at: 2 + 2 * 1)
        let entity = AuthorStruct(
            id: entityId, 
            name: entityReader.read(at: 2 + 2 * 2), 
            notes: ToMany<NoteStruct>.relation(
                            sourceId: EntityId<AuthorStruct>(entityId.value),
                            targetBox: store.box(for: ToMany<NoteStruct>.ReferencedType.self),
                            relationId: 2)
        )
        return entity
    }
}

extension ObjectBox.Box where E == AuthorStruct {

    /// Puts the AuthorStruct in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: AuthorStruct) throws -> AuthorStruct {
        let entityId: AuthorStruct.EntityBindingType.IdType = try self.put(entity)

        return AuthorStruct(
            id: entityId, 
            name: entity.name, 
            notes: entity.notes
        )
    }

    /// Puts the AuthorStructs in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [AuthorStruct]) throws -> [AuthorStruct] {
        let entityIds: [AuthorStruct.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [AuthorStruct]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(AuthorStruct(
                id: entityId, 
                name: entity.name, 
                notes: entity.notes
            ))
        }

        return newEntities
    }
}


extension Note: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Note

    internal var _id: EntityId<Note> {
        return EntityId<Note>(self.id.value)
    }
}

extension Note: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = NoteBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Note", id: 3)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Note.self, id: 3, uid: 6621987164459613696)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 617344484721827328)
        try entityBuilder.addProperty(name: "title", type: PropertyType.string, id: 2, uid: 2471815618275835648)
        try entityBuilder.addProperty(name: "text", type: PropertyType.string, id: 3, uid: 1682679985863644416)
        try entityBuilder.addProperty(name: "creationDate", type: PropertyType.date, id: 4, uid: 7772131268587614208)
        try entityBuilder.addProperty(name: "modificationDate", type: PropertyType.date, id: 5, uid: 3824567602058762496)
        try entityBuilder.addProperty(name: "done", type: PropertyType.bool, id: 7, uid: 4785356838416954880)
        try entityBuilder.addProperty(name: "upvotes", type: PropertyType.int, flags: [.unsigned], id: 8, uid: 7312811264160688896)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, flags: [.indexed, .indexPartialSkipZero], id: 6, uid: 635864004252975104, indexId: 1, indexUid: 6553209938432101120)

        try entityBuilder.lastProperty(id: 8, uid: 7312811264160688896)
    }
}

extension Note {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.id == myId }
    internal static var id: Property<Note, Id, Id> { return Property<Note, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.title.startsWith("X") }
    internal static var title: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.text.startsWith("X") }
    internal static var text: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.creationDate > 1234 }
    internal static var creationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.modificationDate > 1234 }
    internal static var modificationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.done == true }
    internal static var done: Property<Note, Bool, Void> { return Property<Note, Bool, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.upvotes > 1234 }
    internal static var upvotes: Property<Note, UInt32, Void> { return Property<Note, UInt32, Void>(propertyId: 8, isPrimaryKey: false) }
    internal static var author: Property<Note, EntityId<ToOne<Author>.Target>, ToOne<Author>.Target> { return Property(propertyId: 6) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Note {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Note, Id, Id> { return Property<Note, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .title.startsWith("X") }

    internal static var title: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .text.startsWith("X") }

    internal static var text: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .creationDate > 1234 }

    internal static var creationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .modificationDate > 1234 }

    internal static var modificationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .done == true }

    internal static var done: Property<Note, Bool, Void> { return Property<Note, Bool, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .upvotes > 1234 }

    internal static var upvotes: Property<Note, UInt32, Void> { return Property<Note, UInt32, Void>(propertyId: 8, isPrimaryKey: false) }

    internal static var author: Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target> { return Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target>(propertyId: 6) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Note.EntityBindingType`.
internal class NoteBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Note
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_title = propertyCollector.prepare(string: entity.title)
        let propertyOffset_text = propertyCollector.prepare(string: entity.text)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.creationDate, at: 2 + 2 * 4)
        propertyCollector.collect(entity.modificationDate, at: 2 + 2 * 5)
        propertyCollector.collect(entity.done, at: 2 + 2 * 7)
        propertyCollector.collect(entity.upvotes, at: 2 + 2 * 8)
        try propertyCollector.collect(entity.author, at: 2 + 2 * 6, store: store)
        propertyCollector.collect(dataOffset: propertyOffset_title, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_text, at: 2 + 2 * 3)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            entity.author.attach(to: store.box(for: Author.self))
        }
    }
    internal func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: ObjectBox.Id?) {
        switch propertyId {
            case 6:
                entity.author.targetId = (entityId != nil) ? EntityId<Author>(entityId!) : nil
            default:
                fatalError("Attempt to change nonexistent ToOne relation with ID \(propertyId)")
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Note()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.title = entityReader.read(at: 2 + 2 * 2)
        entity.text = entityReader.read(at: 2 + 2 * 3)
        entity.creationDate = entityReader.read(at: 2 + 2 * 4)
        entity.modificationDate = entityReader.read(at: 2 + 2 * 5)
        entity.done = entityReader.read(at: 2 + 2 * 7)
        entity.upvotes = entityReader.read(at: 2 + 2 * 8)

        entity.author = entityReader.read(at: 2 + 2 * 6, store: store)
        return entity
    }
}



extension NoteStruct: ObjectBox.__EntityRelatable {
    internal typealias EntityType = NoteStruct

    internal var _id: EntityId<NoteStruct> {
        return EntityId<NoteStruct>(self.id.value)
    }
}

extension NoteStruct: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = NoteStructBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "NoteStruct", id: 4)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: NoteStruct.self, id: 4, uid: 1207223334387100416)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 3861937013970020352)
        try entityBuilder.addProperty(name: "title", type: PropertyType.string, id: 2, uid: 7299847863773411840)
        try entityBuilder.addProperty(name: "text", type: PropertyType.string, id: 3, uid: 8005796292158566144)
        try entityBuilder.addProperty(name: "creationDate", type: PropertyType.date, id: 4, uid: 2103845948806101248)
        try entityBuilder.addProperty(name: "modificationDate", type: PropertyType.date, id: 5, uid: 8693241810453735680)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, flags: [.indexed, .indexPartialSkipZero], id: 6, uid: 8861632850675438336, indexId: 2, indexUid: 3116818706083195904)

        try entityBuilder.lastProperty(id: 6, uid: 8861632850675438336)
    }
}

extension NoteStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.id == myId }
    internal static var id: Property<NoteStruct, Id, Id> { return Property<NoteStruct, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.title.startsWith("X") }
    internal static var title: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.text.startsWith("X") }
    internal static var text: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.creationDate > 1234 }
    internal static var creationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.modificationDate > 1234 }
    internal static var modificationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 5, isPrimaryKey: false) }
    internal static var author: Property<NoteStruct, EntityId<ToOne<Author>.Target>, ToOne<Author>.Target> { return Property(propertyId: 6) }


    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == NoteStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<NoteStruct, Id, Id> { return Property<NoteStruct, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .title.startsWith("X") }

    internal static var title: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .text.startsWith("X") }

    internal static var text: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .creationDate > 1234 }

    internal static var creationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .modificationDate > 1234 }

    internal static var modificationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 5, isPrimaryKey: false) }

    internal static var author: Property<NoteStruct, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target> { return Property<NoteStruct, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target>(propertyId: 6) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `NoteStruct.EntityBindingType`.
internal class NoteStructBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = NoteStruct
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setStructEntityId(of entity: inout EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_title = propertyCollector.prepare(string: entity.title)
        let propertyOffset_text = propertyCollector.prepare(string: entity.text)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.creationDate, at: 2 + 2 * 4)
        propertyCollector.collect(entity.modificationDate, at: 2 + 2 * 5)
        try propertyCollector.collect(entity.author, at: 2 + 2 * 6, store: store)
        propertyCollector.collect(dataOffset: propertyOffset_title, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_text, at: 2 + 2 * 3)
    }

    internal func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: ObjectBox.Id?) {
        switch propertyId {
            case 6:
                entity.author.targetId = (entityId != nil) ? EntityId<Author>(entityId!) : nil
            default:
                fatalError("Attempt to change nonexistent ToOne relation with ID \(propertyId)")
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entityId: Id = entityReader.read(at: 2 + 2 * 1)
        let entity = NoteStruct(
            id: entityId, 
            title: entityReader.read(at: 2 + 2 * 2), 
            text: entityReader.read(at: 2 + 2 * 3), 
            creationDate: entityReader.read(at: 2 + 2 * 4), 
            modificationDate: entityReader.read(at: 2 + 2 * 5), 
            author: entityReader.read(at: 2 + 2 * 6, store: store)
        )
        return entity
    }
}

extension ObjectBox.Box where E == NoteStruct {

    /// Puts the NoteStruct in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: NoteStruct) throws -> NoteStruct {
        let entityId: NoteStruct.EntityBindingType.IdType = try self.put(entity)

        return NoteStruct(
            id: entityId, 
            title: entity.title, 
            text: entity.text, 
            creationDate: entity.creationDate, 
            modificationDate: entity.modificationDate, 
            author: entity.author
        )
    }

    /// Puts the NoteStructs in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [NoteStruct]) throws -> [NoteStruct] {
        let entityIds: [NoteStruct.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [NoteStruct]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(NoteStruct(
                id: entityId, 
                title: entity.title, 
                text: entity.text, 
                creationDate: entity.creationDate, 
                modificationDate: entity.modificationDate, 
                author: entity.author
            ))
        }

        return newEntities
    }
}


extension Student: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Student

    internal var _id: EntityId<Student> {
        return EntityId<Student>(self.id.value)
    }
}

extension Student: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = StudentBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Student", id: 5)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Student.self, id: 5, uid: 7379166351890261760)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 4727709093274848000)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 6177266951475952640)
        try entityBuilder.addToManyRelation(id: 3, uid: 2411668051953007360,
                                            targetId: 6, targetUid: 3069437699900361728)

        try entityBuilder.lastProperty(id: 2, uid: 6177266951475952640)
    }
}

extension Student {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Student.id == myId }
    internal static var id: Property<Student, Id, Id> { return Property<Student, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Student.name.startsWith("X") }
    internal static var name: Property<Student, String, Void> { return Property<Student, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `Student.teachers` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var teachers: ToManyProperty<Teacher> { return ToManyProperty(.relationId(3)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Student {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Student, Id, Id> { return Property<Student, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Student, String, Void> { return Property<Student, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.teachers` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var teachers: ToManyProperty<Teacher> { return ToManyProperty(.relationId(3)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Student.EntityBindingType`.
internal class StudentBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Student
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            let teachers = ToMany<Teacher>.relation(
                sourceId: EntityId<Student>(id.value),
                targetBox: store.box(for: ToMany<Teacher>.ReferencedType.self),
                relationId: 3)
            if !entity.teachers.isEmpty {
                teachers.replace(entity.teachers)
            }
            entity.teachers = teachers
            try entity.teachers.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Student()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.teachers = ToMany<Teacher>.relation(
            sourceId: EntityId<Student>(entity.id.value),
            targetBox: store.box(for: ToMany<Teacher>.ReferencedType.self),
            relationId: 3)
        return entity
    }
}



extension Teacher: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Teacher

    internal var _id: EntityId<Teacher> {
        return EntityId<Teacher>(self.id.value)
    }
}

extension Teacher: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = TeacherBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Teacher", id: 6)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Teacher.self, id: 6, uid: 3069437699900361728)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 832346188601716224)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 5783953787623103488)

        try entityBuilder.lastProperty(id: 2, uid: 5783953787623103488)
    }
}

extension Teacher {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Teacher.id == myId }
    internal static var id: Property<Teacher, Id, Id> { return Property<Teacher, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Teacher.name.startsWith("X") }
    internal static var name: Property<Teacher, String, Void> { return Property<Teacher, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `Teacher.students` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var students: ToManyProperty<Student> { return ToManyProperty(.backlinkRelationId(3)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Teacher {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Teacher, Id, Id> { return Property<Teacher, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Teacher, String, Void> { return Property<Teacher, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.students` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var students: ToManyProperty<Student> { return ToManyProperty(.backlinkRelationId(3)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Teacher.EntityBindingType`.
internal class TeacherBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Teacher
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            let students = ToMany<Student>.backlink(
                sourceBox: store.box(for: ToMany<Student>.ReferencedType.self),
                targetId: EntityId<Teacher>(id.value),
                relationId: 3)
            if !entity.students.isEmpty {
                students.replace(entity.students)
            }
            entity.students = students
            try entity.students.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Teacher()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.students = ToMany<Student>.backlink(
            sourceBox: store.box(for: ToMany<Student>.ReferencedType.self),
            targetId: EntityId<Teacher>(entity.id.value),
            relationId: 3)
        return entity
    }
}


/// Helper function that allows calling Enum(rawValue: value) with a nil value, which will return nil.
fileprivate func optConstruct<T: RawRepresentable>(_ type: T.Type, rawValue: T.RawValue?) -> T? {
    guard let rawValue = rawValue else { return nil }
    return T(rawValue: rawValue)
}

// MARK: - Store setup

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ObjectBox.ModelBuilder()
    try Author.buildEntity(modelBuilder: modelBuilder)
    try AuthorStruct.buildEntity(modelBuilder: modelBuilder)
    try Note.buildEntity(modelBuilder: modelBuilder)
    try NoteStruct.buildEntity(modelBuilder: modelBuilder)
    try Student.buildEntity(modelBuilder: modelBuilder)
    try Teacher.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 6, uid: 3069437699900361728)
    modelBuilder.lastIndex(id: 2, uid: 3116818706083195904)
    modelBuilder.lastRelation(id: 3, uid: 2411668051953007360)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// # In-memory database
    /// To use a file-less in-memory database, instead of a directory path pass `memory:` 
    /// together with an identifier string:
    /// ```swift
    /// let inMemoryStore = try Store(directoryPath: "memory:test-db")
    /// ```
    ///
    /// - Parameters:
    ///   - directoryPath: The directory path in which ObjectBox places its database files for this store,
    ///     or to use an in-memory database `memory:<identifier>`.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o644`.
    ///     Note: directories become searchable if the "read" or "write" permission is set (e.g. 0640 becomes 0750).
    ///   - maxReaders: The maximum number of readers.
    ///     "Readers" are a finite resource for which we need to define a maximum number upfront.
    ///     The default value is enough for most apps and usually you can ignore it completely.
    ///     However, if you get the maxReadersExceeded error, you should verify your
    ///     threading. For each thread, ObjectBox uses multiple readers. Their number (per thread) depends
    ///     on number of types, relations, and usage patterns. Thus, if you are working with many threads
    ///     (e.g. in a server-like scenario), it can make sense to increase the maximum number of readers.
    ///     Note: The internal default is currently around 120. So when hitting this limit, try values around 200-500.
    ///   - readOnly: Opens the database in read-only mode, i.e. not allowing write transactions.
    ///
    /// - important: This initializer is created by the code generator. If you only see the internal `init(model:...)`
    ///              initializer, trigger code generation by building your project.
    internal convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024,
                            fileMode: UInt32 = 0o644, maxReaders: UInt32 = 0, readOnly: Bool = false) throws {
        try self.init(
            model: try cModel(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders,
            readOnly: readOnly)
    }
}

// swiftlint:enable all
