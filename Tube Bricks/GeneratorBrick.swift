//
//  GeneratorBrick.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 05.11.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa
import RealmSwift

class GeneratorBrick: Object {
    dynamic var brick: Brick?
    dynamic var separator: Separator?
    var generator: LinkingObjects<Generator> {
        return LinkingObjects(fromType: Generator.self, property: "generatorBricks")
    }
}
