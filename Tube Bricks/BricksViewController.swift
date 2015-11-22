//
//  BricksViewController.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 29.10.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa
import RealmSwift

class BricksViewController: NSViewController {
    var allBricks: Results<Brick> = try! Realm().objects(Brick).sorted("title")
    var bricks: Results<Brick> = try! Realm().objects(Brick).sorted("title")
    
    var dataFilePath: String?
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var addButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func selectedBrick() -> Brick? {
        let selectedRow = self.tableView.selectedRow;
        if selectedRow >= 0 && selectedRow < bricks.count {
            return self.bricks[selectedRow]
        }
        return nil
    }
    
    func updateDetailInfo(data: Brick?) {
        var title = ""
        var text = ""
        if let brick = data {
            title = brick.title
            text = brick.text
        }
        self.textField.stringValue = title
        self.textView.string = text
    }
    
    func reloadBrickRow(row: Int) {
        let indexSet = NSIndexSet(index: row)
        let columnSet = NSIndexSet(index: 0)
        self.tableView.reloadDataForRowIndexes(indexSet, columnIndexes: columnSet)
    }
    
}

// MARK: IBActions
extension BricksViewController{
   
    func sendAddDeleteNotification(){
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "AddDelete", object: nil))
    }
    
    @IBAction func search(sender: AnyObject) {
        let searchField = sender as! NSSearchField
        tableView.deselectRow(tableView.selectedRow)
        if searchField.stringValue.isEmpty {
            bricks = allBricks
            tableView.reloadData()
        }else{
            bricks = allBricks.filter("title contains[c] %a", searchField.stringValue)
            tableView.reloadData()
        }
        
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if let selectedData = selectedBrick() {
            let selectedRow = bricks.indexOf(selectedData)
            let realm = try! Realm()
            try! realm.write{
                selectedData.title = self.textField.stringValue
                selectedData.text = self.textView.string!
            }
            let newSelectedRow = bricks.indexOf(selectedData)
            self.tableView.moveRowAtIndex(selectedRow!, toIndex: newSelectedRow!)
            self.reloadBrickRow(newSelectedRow!)
        }
        sendAddDeleteNotification()
    }
    
    @IBAction func addButtonPressed(sender: AnyObject){
        let newData = Brick(value: ["title": "New Entry", "text": ""])
        let realm = try! Realm()
        try! realm.write{
            realm.add(newData)
            if let newRowIndex = self.bricks.indexOf(newData){
                self.tableView.insertRowsAtIndexes(NSIndexSet(index: newRowIndex), withAnimation: NSTableViewAnimationOptions.EffectFade)
                self.tableView.selectRowIndexes(NSIndexSet(index: newRowIndex), byExtendingSelection:false)
                self.tableView.scrollRowToVisible(newRowIndex)
            }
        }
        sendAddDeleteNotification()
    }
    
    @IBAction func removeButtonPressed(sender: AnyObject){
        if let selectedBrick = selectedBrick() {
            let realm = try! Realm()
            let generatorBricks = realm.objects(GeneratorBrick).filter("brick = %a", selectedBrick)
            try! realm.write{
                for generatorBrick in generatorBricks {
                    realm.delete(generatorBrick)
                }
                realm.delete(selectedBrick)
                self.tableView.removeRowsAtIndexes(NSIndexSet(index:self.tableView.selectedRow),
                    withAnimation: NSTableViewAnimationOptions.EffectFade)
                self.updateDetailInfo(nil)
            }
            sendAddDeleteNotification()
        }
    }
    
}

// MARK: - NSTableViewDataSource
extension BricksViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return Int(self.bricks.count)
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
            
        let Brick = self.bricks[row]
        cellView.textField!.stringValue = Brick.title
        
        return cellView
    }
}

    // MARK: - NSTableViewDelegate
extension BricksViewController: NSTableViewDelegate {
    
    @IBAction func endEditingText(sender: AnyObject){
        let textField = sender as! NSTextField
        let index = tableView.rowForView(textField)
        if index >= 0 {
            let brick = bricks[index]
            try! Realm().write{
                brick.title = textField.stringValue
            }
            if let newIndex = bricks.indexOf(brick) {
                if index != newIndex {
                    tableView.moveRowAtIndex(index, toIndex: newIndex)
                }
            }
            updateDetailInfo(brick)
            sendAddDeleteNotification()
        }
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedData = selectedBrick()
        updateDetailInfo(selectedData)
        let buttonsEnabled = (selectedData != nil)
        textField.enabled = buttonsEnabled
        textView.editable = buttonsEnabled
        textView.selectable = buttonsEnabled
        deleteButton.enabled = buttonsEnabled
        saveButton.enabled = buttonsEnabled
    }
}























