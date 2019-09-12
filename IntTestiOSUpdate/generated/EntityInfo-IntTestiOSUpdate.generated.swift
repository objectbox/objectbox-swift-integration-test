// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata


extension Note: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Note

    internal var _id: Id<Note> {
        return self.id
    }
}

extension Note: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = NoteBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Note", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Note.self, id: 1, uid: 2809383601464355072)
        try entityBuilder.addProperty(name: "id", type: Id<Note>.entityPropertyType, flags: [.id], id: 1, uid: 6165973864757371648)

        try entityBuilder.lastProperty(id: 1, uid: 6165973864757371648)
    }
}

extension Note {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.id == myId }
    internal static var id: Property<Note, Id<Note>> { return Property<Note, Id<Note>>(propertyId: 1, isPrimaryKey: true) }

    fileprivate func __setId(identifier: ObjectBox.EntityId) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Note {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    static var id: Property<Note, Id<Note>> { return Property<Note, Id<Note>>(propertyId: 1, isPrimaryKey: true) }


}


/// Generated service type to handle persisting and reading entity data. Exposed through `Note.EntityBindingType`.
internal class NoteBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Note

    override internal required init() {}

    internal func setEntityId(of entity: EntityType, to entityId: ObjectBox.EntityId) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.EntityId {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: EntityId, propertyCollector: PropertyCollector, store: Store) {


        propertyCollector.collect(id, at: 2 + 2 * 1)


    }

    internal func createEntity(entityReader: EntityReader, store: Store) -> EntityType {
        let entity = Note()

        entity.id = entityReader.read(at: 2 + 2 * 1)



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
    let modelBuilder = try ModelBuilder()
    try Note.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 1, uid: 2809383601464355072)
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
