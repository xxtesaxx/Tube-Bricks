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
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                migration.enumerateObjects(ofType: Brick.className()) { oldObject, newObject in
                    if (oldSchemaVersion < 2) {
                        
                    }
                }
                migration.enumerateObjects(ofType: Separator.className(),{ (oldObject, newObject) -> Void in
                    if (oldSchemaVersion < 2) {
                        
                    }
                })
                migration.enumerateObjects(ofType: Generator.className(),{ (oldObject, newObject) -> Void in
                    if (oldSchemaVersion < 2) {
                    }
                })
                migration.enumerateObjects(ofType: GeneratorBrick.className(),{ (oldObject, newObject) -> Void in
                    if (oldSchemaVersion < 2) {
                    }
                })
        })
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden;
        self.window?.titlebarAppearsTransparent = true;
        self.window?.styleMask.insert(.fullSizeContentView)
        self.shouldCascadeWindows = false
        self.windowFrameAutosaveName = "TubeBricksWindow"
    }
}
