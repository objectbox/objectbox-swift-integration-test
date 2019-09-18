// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata

extension Author: ObjectBox.Entity {}
extension AuthorStruct: ObjectBox.Entity {}
extension NoteStruct: ObjectBox.Entity {}

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
        let entityBuilder = try modelBuilder.entityBuilder(for: Author.self, id: 1, uid: 1929015859046408192)
        try entityBuilder.addProperty(name: "id", type: EntityId<Author>.entityPropertyType, flags: [.id], id: 1, uid: 2900800177041107712)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 2, uid: 6615236515020913152)
        try entityBuilder.addToManyRelation(id: 1, uid: 818851024577826048,
                                            targetId: 2, targetUid: 2938133627900000768)

        try entityBuilder.lastProperty(id: 2, uid: 6615236515020913152)
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
    /// Use `Author.notesStandalone` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notesStandalone: ToManyProperty<Author, Note> { return ToManyProperty(.relationId(1)) }

    /// Use `Author.notes` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<Author, Note> { return ToManyProperty(.valuePropertyId(6)) }


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

    /// Use `.notesStandalone` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notesStandalone: ToManyProperty<Author, Note> { return ToManyProperty(.relationId(1)) }

    /// Use `.notes` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<Author, Note> { return ToManyProperty(.valuePropertyId(6)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Author.EntityBindingType`.
internal class AuthorBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Author
    internal typealias IdType = EntityId<Author>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.PropertyCollector, store: ObjectBox.Store) {
        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.name, at: 2 + 2 * 2), 2 + 2 * 2))

        propertyCollector.collect(id, at: 2 + 2 * 1)


        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
            let notesStandalone = ToMany<Note, Author>.relation(
                sourceBox: store.box(for: ToMany<Note, Author>.OwningType.self),
                sourceId: EntityId<ToMany<Note, Author>.OwningType>(id.value),
                targetBox: store.box(for: ToMany<Note, Author>.ReferencedType.self),
                relationId: 1)
            if !entity.notesStandalone.isEmpty {
                notesStandalone.replace(entity.notesStandalone)
            }
            entity.notesStandalone = notesStandalone
            let notes = ToMany<Note, Author>.backlink(
                sourceBox: store.box(for: ToMany<Note, Author>.ReferencedType.self),
                sourceProperty: ToMany<Note, Author>.ReferencedType.author,
                targetId: EntityId<ToMany<Note, Author>.OwningType>(id.value))
            if !entity.notes.isEmpty {
                notes.replace(entity.notes)
            }
            entity.notes = notes
        }
    }
    internal func createEntity(entityReader: ObjectBox.EntityReader, store: ObjectBox.Store) -> EntityType {
        let entity = Author()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.notesStandalone = ToMany<Note, Author>.relation(
            sourceBox: store.box(for: ToMany<Note, Author>.OwningType.self),
            sourceId: EntityId<ToMany<Note, Author>.OwningType>(entity.id.value),
            targetBox: store.box(for: ToMany<Note, Author>.ReferencedType.self),
            relationId: 1)
        entity.notes = ToMany<Note, Author>.backlink(
            sourceBox: store.box(for: ToMany<Note, Author>.ReferencedType.self),
            sourceProperty: ToMany<Note, Author>.ReferencedType.author,
            targetId: EntityId<ToMany<Note, Author>.OwningType>(entity.id.value))
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
    internal static var entityInfo = ObjectBox.EntityInfo(name: "AuthorStruct", id: 3)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: AuthorStruct.self, id: 3, uid: 8487821801970196992)
        try entityBuilder.addProperty(name: "id", type: EntityId<AuthorStruct>.entityPropertyType, flags: [.id], id: 1, uid: 3465244931676925440)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 2, uid: 7396549316336739584)
        try entityBuilder.addToManyRelation(id: 2, uid: 1980637644033212928,
                                            targetId: 4, targetUid: 5165970882468521216)

        try entityBuilder.lastProperty(id: 2, uid: 7396549316336739584)
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

    internal static var notes: ToManyProperty<AuthorStruct, NoteStruct> { return ToManyProperty(.relationId(2)) }

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

    internal static var notes: ToManyProperty<AuthorStruct, NoteStruct> { return ToManyProperty(.relationId(2)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `AuthorStruct.EntityBindingType`.
internal class AuthorStructBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = AuthorStruct
    internal typealias IdType = EntityId<AuthorStruct>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        // Use the struct variants of the put methods on entities of struct AuthorStruct.
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.PropertyCollector, store: ObjectBox.Store) {
        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.name, at: 2 + 2 * 2), 2 + 2 * 2))

        propertyCollector.collect(id, at: 2 + 2 * 1)


        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func createEntity(entityReader: ObjectBox.EntityReader, store: ObjectBox.Store) -> EntityType {
        let entityId: EntityId<AuthorStruct> = entityReader.read(at: 2 + 2 * 1)
        let entity = AuthorStruct(
            id: entityId, 
            name: entityReader.read(at: 2 + 2 * 2), 
            notes: ToMany<NoteStruct, AuthorStruct>.relation(
                            sourceBox: store.box(for: ToMany<NoteStruct, AuthorStruct>.OwningType.self),
                            sourceId: EntityId<ToMany<NoteStruct, AuthorStruct>.OwningType>(entityId.value),
                            targetBox: store.box(for: ToMany<NoteStruct, AuthorStruct>.ReferencedType.self),
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
        let entityIds: [AuthorStruct.EntityBindingType.IdType] = try self.put(entities)
        var newEntities = [AuthorStruct]()

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
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Note", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Note.self, id: 2, uid: 2938133627900000768)
        try entityBuilder.addProperty(name: "id", type: Id.entityPropertyType, flags: [.id], id: 1, uid: 5167044809936833536)
        try entityBuilder.addProperty(name: "title", type: String.entityPropertyType, id: 2, uid: 106626844958824192)
        try entityBuilder.addProperty(name: "text", type: String.entityPropertyType, id: 3, uid: 8439158285230343936)
        try entityBuilder.addProperty(name: "creationDate", type: Date.entityPropertyType, id: 4, uid: 1991401841250851072)
        try entityBuilder.addProperty(name: "modificationDate", type: Date.entityPropertyType, id: 5, uid: 1032771270938277888)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, id: 6, uid: 542781284570685696, indexId: 1, indexUid: 4249409595716153088)

        try entityBuilder.lastProperty(id: 6, uid: 542781284570685696)
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

    internal static var author: Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target> { return Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target>(propertyId: 6) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Note.EntityBindingType`.
internal class NoteBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Note
    internal typealias IdType = Id

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.PropertyCollector, store: ObjectBox.Store) {
        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.title, at: 2 + 2 * 2), 2 + 2 * 2))
        offsets.append((propertyCollector.prepare(string: entity.text, at: 2 + 2 * 3), 2 + 2 * 3))

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.creationDate, at: 2 + 2 * 4)
        propertyCollector.collect(entity.modificationDate, at: 2 + 2 * 5)

        propertyCollector.collect(entity.author, at: 2 + 2 * 6, store: store)

        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
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
    internal func createEntity(entityReader: ObjectBox.EntityReader, store: ObjectBox.Store) -> EntityType {
        let entity = Note()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.title = entityReader.read(at: 2 + 2 * 2)
        entity.text = entityReader.read(at: 2 + 2 * 3)
        entity.creationDate = entityReader.read(at: 2 + 2 * 4)
        entity.modificationDate = entityReader.read(at: 2 + 2 * 5)

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
        let entityBuilder = try modelBuilder.entityBuilder(for: NoteStruct.self, id: 4, uid: 5165970882468521216)
        try entityBuilder.addProperty(name: "id", type: Id.entityPropertyType, flags: [.id], id: 1, uid: 6273628422701849088)
        try entityBuilder.addProperty(name: "title", type: String.entityPropertyType, id: 2, uid: 7056067094280675840)
        try entityBuilder.addProperty(name: "text", type: String.entityPropertyType, id: 3, uid: 7712887951442338304)
        try entityBuilder.addProperty(name: "creationDate", type: Date.entityPropertyType, id: 4, uid: 8346543372345148416)
        try entityBuilder.addProperty(name: "modificationDate", type: Date.entityPropertyType, id: 5, uid: 1756048498335405312)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, id: 6, uid: 5562157089393177856, indexId: 2, indexUid: 7515899661869751296)

        try entityBuilder.lastProperty(id: 6, uid: 5562157089393177856)
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
internal class NoteStructBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = NoteStruct
    internal typealias IdType = Id

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        // Use the struct variants of the put methods on entities of struct NoteStruct.
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.PropertyCollector, store: ObjectBox.Store) {
        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.title, at: 2 + 2 * 2), 2 + 2 * 2))
        offsets.append((propertyCollector.prepare(string: entity.text, at: 2 + 2 * 3), 2 + 2 * 3))

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.creationDate, at: 2 + 2 * 4)
        propertyCollector.collect(entity.modificationDate, at: 2 + 2 * 5)

        propertyCollector.collect(entity.author, at: 2 + 2 * 6, store: store)

        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
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
    internal func createEntity(entityReader: ObjectBox.EntityReader, store: ObjectBox.Store) -> EntityType {
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
        let entityIds: [NoteStruct.EntityBindingType.IdType] = try self.put(entities)
        var newEntities = [NoteStruct]()

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
    modelBuilder.lastEntity(id: 4, uid: 5165970882468521216)
    modelBuilder.lastIndex(id: 2, uid: 7515899661869751296)
    modelBuilder.lastRelation(id: 2, uid: 1980637644033212928)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// - Parameters:
    ///   - directoryPath: Directory path to store database files in.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o755`.
    ///   - maxReaders: Maximum amount of concurrent readers, tailored to your use case. Default is `0` (unlimited).
    internal convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024, fileMode: UInt32 = 0o755, maxReaders: UInt32 = 0) throws {
        try self.init(
            model: try cModel(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders)
    }
}

// swiftlint:enable all
