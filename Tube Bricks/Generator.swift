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
    dynamic var title: String = ""
    dynamic var headerText: String = ""
    dynamic var footerText: String = ""
    dynamic var headerSeparator: Separator?
    dynamic var footerSeparator: Separator?
    dynamic var isDefault: Bool = false
    let generatorBricks = List<GeneratorBrick>()
}
