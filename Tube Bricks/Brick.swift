//
//  Brick.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 29.10.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa
import RealmSwift

class Brick: Object {
    dynamic var title: String = ""
    dynamic var text: String = ""
    var generatorBricks: LinkingObjects<GeneratorBrick> {
        return LinkingObjects(fromType: GeneratorBrick.self, property: "brick")
    }
}

