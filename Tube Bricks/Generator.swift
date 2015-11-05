//
//  Generator.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 04.11.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa
import RealmSwift

class Generator: Object {
    dynamic var headerText: String = ""
    dynamic var footerText: String = ""
    dynamic var headerSeparator: Separator?
    dynamic var footerSeparator: Separator?
    var bricks = List<Brick>()
}
