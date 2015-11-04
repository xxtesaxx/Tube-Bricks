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
    
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
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
        if let Brick = data {
            title = Brick.title
            text = Brick.text
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
    
    @IBAction func segmentedControlPressed(sender: AnyObject) {
        let selectedIndex = segmentedControl.selectedSegment
        segmentedControl.selectedSegment = -1
        
        if(selectedIndex == 0){
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
        }else {
            if let selectedBrick = selectedBrick() {
                let realm = try! Realm()
                try! realm.write{
                    realm.delete(selectedBrick)
                    self.tableView.removeRowsAtIndexes(NSIndexSet(index:self.tableView.selectedRow),
                        withAnimation: NSTableViewAnimationOptions.EffectFade)
                    self.updateDetailInfo(nil)
                }
            }
        }
        sendAddDeleteNotification()
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
    func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedData = selectedBrick()
        updateDetailInfo(selectedData)
        let buttonsEnabled = (selectedData != nil)
        textField.enabled = buttonsEnabled
        textView.editable = buttonsEnabled
        textView.selectable = buttonsEnabled
        segmentedControl.setEnabled(buttonsEnabled, forSegment: 1)
        saveButton.enabled = buttonsEnabled
    }
}























