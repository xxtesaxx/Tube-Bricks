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
    dynamic var positionInGenerator: Int = -1
    var generator: [Generator] {
        return linkingObjects(Generator.self, forProperty: "generatorBricks")
    }
}
