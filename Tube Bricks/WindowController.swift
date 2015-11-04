//
//  WindowController.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 29.10.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa
import RealmSwift

class WindowController: NSWindowController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                migration.enumerate(Brick.className()) { oldObject, newObject in
                    if (oldSchemaVersion < 1) {
                        NSLog("Migrating Brick \(oldObject) to Brick \(newObject) in v1")
                    }
                }
                migration.enumerate(Separator.className(),{ (oldObject, newObject) -> Void in
                    if (oldSchemaVersion < 1) {
                        NSLog("Migrating Separator \(oldObject) to Separator \(newObject) in v1")
                    }
                })
        })
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
    
    override func windowDidLoad() {
        self.window?.titleVisibility = NSWindowTitleVisibility.Hidden;
        self.window?.titlebarAppearsTransparent = true;
        self.window?.styleMask |= NSFullSizeContentViewWindowMask;
//        self.window?.titlebarAppearsTransparent = true
//        self.window?.movableByWindowBackground  = true
    }
}
