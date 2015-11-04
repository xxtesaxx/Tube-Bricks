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
    dynamic var inGenerator: Bool = false
    dynamic var positionInGenerator: Int = -1
    dynamic var separator: Separator?
}

