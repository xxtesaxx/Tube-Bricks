//
//  GeneratorViewController.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 29.10.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa
import RealmSwift

class GeneratorViewController: NSViewController {

    @IBOutlet weak var footerSeparatorComboBox: NSComboBox!
    @IBOutlet weak var headerSeparatorComboBox: NSComboBox!
    @IBOutlet weak var bricksSourceTableView: NSTableView!
    @IBOutlet weak var bricksDestinationTableView: NSTableView!
    @IBOutlet var headerTextView: NSTextView!
    @IBOutlet var footerTextView: NSTextView!
    
    var allSourceBricks: Results<Brick> = try! Realm().objects(Brick).filter("inGenerator = false").sorted("title")
    var sourceBricks: Results<Brick> = try! Realm().objects(Brick).filter("inGenerator = false").sorted("title")
    var destinationBricks: Results<Brick> = try! Realm().objects(Brick).filter("inGenerator = true").sorted("positionInGenerator")

    var separators: Results<Separator> = try! Realm().objects(Separator).sorted("title")

    let generator: Generator = {
        let realm = try! Realm()
        let obj = realm.objects(Generator).first
        if obj != nil {
            return obj!
        }
        let newObj = Generator()
        try! realm.write { realm.add(newObj) }
        return newObj
    }()
    
    var isReloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI:", name: "AddDelete", object: nil)
        
        headerTextView.string = generator.headerText
        footerTextView.string = generator.footerText
        
        updateHeaderFooterSeparator()
    }
    
    func updateUI(sender: AnyObject){
        self.isReloading = true
        bricksSourceTableView.reloadData()
        bricksDestinationTableView.reloadData()
        updateHeaderFooterSeparator()
        self.isReloading = false
    }
    
    func updateHeaderFooterSeparator(){
        headerSeparatorComboBox.removeAllItems()
        headerSeparatorComboBox.addItemWithObjectValue("None")
        for (_, value) in separators.enumerate() {
            headerSeparatorComboBox.addItemWithObjectValue(value.title)
        }
        if let headerSeparator = generator.headerSeparator {
            let index = separators.indexOf(headerSeparator)! + 1
            headerSeparatorComboBox.selectItemAtIndex(index)
        }else {
            headerSeparatorComboBox.selectItemAtIndex(0)
        }
        
        footerSeparatorComboBox.removeAllItems()
        footerSeparatorComboBox.addItemWithObjectValue("None")
        for (_, value) in separators.enumerate() {
            footerSeparatorComboBox.addItemWithObjectValue(value.title)
        }
        
        if let footerSeparator = generator.footerSeparator {
            let index = separators.indexOf(footerSeparator)! + 1
            footerSeparatorComboBox.selectItemAtIndex(index)
        }else {
            footerSeparatorComboBox.selectItemAtIndex(0)
        }
    }
}

extension GeneratorViewController {

    @IBAction func search(sender: AnyObject) {
        let searchField = sender as! NSSearchField
        bricksSourceTableView.deselectAll(bricksSourceTableView)
        if searchField.stringValue.isEmpty {
            sourceBricks = allSourceBricks
            bricksSourceTableView.reloadData()
        }else{
            sourceBricks = allSourceBricks.filter("title contains[c] %a", searchField.stringValue)
            bricksSourceTableView.reloadData()
        }
    }
    
    
    @IBAction func addButton(sender: AnyObject) {
        var bricksToMove = [Brick]()
        for index in bricksSourceTableView.selectedRowIndexes {
            bricksToMove.append(sourceBricks[index])
        }
        let realm = try! Realm()
        try! realm.write {
            for brick in bricksToMove {
                brick.inGenerator = true
                brick.positionInGenerator = (self.destinationBricks.max("positionInGenerator") as Int?)! + 1
            }
        }

        let indexesToInsert = NSMutableIndexSet()
        for brick in bricksToMove {
            indexesToInsert.addIndex(destinationBricks.indexOf(brick)!)
        }
        bricksSourceTableView.removeRowsAtIndexes(bricksSourceTableView.selectedRowIndexes, withAnimation: NSTableViewAnimationOptions.EffectFade)
        bricksDestinationTableView.insertRowsAtIndexes(indexesToInsert, withAnimation: NSTableViewAnimationOptions.EffectFade)
        
        self.bricksDestinationTableView.scrollRowToVisible(indexesToInsert.maxElement()!)
    }

    @IBAction func removeButton(sender: AnyObject) {
        var bricksToMove = [Brick]()
        for index in bricksDestinationTableView.selectedRowIndexes {
            bricksToMove.append(destinationBricks[index])
        }
        let realm = try! Realm()
        try! realm.write {
            for brick in bricksToMove {
                brick.inGenerator = false
                brick.positionInGenerator = -1
            }
        }
        
        let indexesToInsert = NSMutableIndexSet()
        for brick in bricksToMove {
            if let index = sourceBricks.indexOf(brick) {
                indexesToInsert.addIndex(index)
            }
        }
        bricksDestinationTableView.removeRowsAtIndexes(bricksDestinationTableView.selectedRowIndexes, withAnimation: NSTableViewAnimationOptions.EffectFade)
        bricksSourceTableView.insertRowsAtIndexes(indexesToInsert, withAnimation: NSTableViewAnimationOptions.EffectFade)
    }
    
    @IBAction func moveUpButton(sender: AnyObject) {
        for index in bricksDestinationTableView.selectedRowIndexes {
            if index > 0 && index < destinationBricks.count {
                let firstItem = destinationBricks[index - 1]
                let secondItem = destinationBricks[index]
                try! Realm().write{
                    let tmp = firstItem.positionInGenerator
                    firstItem.positionInGenerator = secondItem.positionInGenerator
                    secondItem.positionInGenerator = tmp
                }
                bricksDestinationTableView.moveRowAtIndex(index, toIndex: index - 1)
            }
        }
    }
    
    @IBAction func moveDownButton(sender: AnyObject) {
        for index in bricksDestinationTableView.selectedRowIndexes.reverse() {
            if index >= 0 && index < destinationBricks.count-1 {
                let firstItem = destinationBricks[index + 1]
                let secondItem = destinationBricks[index]
                try! Realm().write{
                    let tmp = firstItem.positionInGenerator
                    firstItem.positionInGenerator = secondItem.positionInGenerator
                    secondItem.positionInGenerator = tmp
                }
                bricksDestinationTableView.moveRowAtIndex(index, toIndex: index + 1)
            }
        }
    }
    
    @IBAction func generateButton(sender: AnyObject) {
        var string = String()
        string += headerTextView.string!
        if let separator = generator.headerSeparator {
            string += separator.text
        }
        for brick in destinationBricks {
            string += brick.text
            if let separator = brick.separator {
                string += separator.text
            }
        }
        if let separator = generator.footerSeparator {
            string += separator.text
        }
        string += footerTextView.string!
        NSLog("Text lautet:\n\(string)")
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.clearContents()
        pasteboard.writeObjects([string])
    }
}

extension GeneratorViewController: NSTextViewDelegate {
    func textDidChange(notification: NSNotification) {
        try! Realm().write{
            self.generator.headerText = self.headerTextView.string!
            self.generator.footerText = self.footerTextView.string!
        }
    }
}

extension GeneratorViewController: NSTableViewDelegate {

}

extension GeneratorViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        if aTableView.isEqual(bricksSourceTableView) {
            return self.sourceBricks.count
        }
        if aTableView.isEqual(bricksDestinationTableView) {
            return self.destinationBricks.count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self)
        
        if tableView.isEqual(bricksSourceTableView) {
            let brick = self.sourceBricks[row]
            (cellView as! NSTableCellView).textField!.stringValue = brick.title
        }
        if tableView.isEqual(bricksDestinationTableView) {
            let brick = self.destinationBricks[row]
            (cellView as! GeneratorDestinationTableCellView).textField!.stringValue = brick.title
            
            //Combobox für Separators mit daten füllen
            let cb = (cellView as! GeneratorDestinationTableCellView).comboBox
            cb.removeAllItems()
            cb.addItemWithObjectValue("None")
            for separator in separators {
                cb.addItemWithObjectValue(separator.title)
            }
            //Richtigen Separator in der Combobox auswählen
            if let separator = brick.separator {
                if let index = separators.indexOf(separator) {
                    cb.selectItemAtIndex(index + 1)
                }
            } else {
                cb.selectItemAtIndex(0)
            }
        }
        return cellView
    }
}

extension GeneratorViewController: NSComboBoxDelegate {
    func comboBoxSelectionDidChange(notification: NSNotification) {
        if let cb = notification.object as? NSComboBox{
            if cb.isEqual(headerSeparatorComboBox) && isReloading == false {
                var separator: Separator? = nil
            
                if cb.indexOfSelectedItem > 0 {
                    separator = separators[cb.indexOfSelectedItem - 1]
                }
                
                try! Realm().write{
                    self.generator.headerSeparator = separator
                }
                
            } else if cb.isEqual(footerSeparatorComboBox) && isReloading == false {
                var separator: Separator? = nil
                
                if cb.indexOfSelectedItem > 0 {
                    separator = separators[cb.indexOfSelectedItem - 1]
                }
                
                try! Realm().write{
                    self.generator.footerSeparator = separator
                }
            } else {
                let index = bricksDestinationTableView.rowForView(cb)
                if index >= 0 && index < destinationBricks.count {
                    let brick = destinationBricks[index]
                    var separator: Separator? = nil
                    if cb.indexOfSelectedItem > 0 {
                        separator = separators[cb.indexOfSelectedItem - 1]
                    }
                    try! Realm().write{
                        brick.separator = separator
                    }
                }
            }
        }
    }
}













