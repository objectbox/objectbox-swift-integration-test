//
//  Copyright © 2026 ObjectBox Ltd. All rights reserved.
//

import ObjectBox

// objectbox: sync
class Foo: Entity {
    var id: EntityId<Foo> = 0
    var bar: String = ""
}
