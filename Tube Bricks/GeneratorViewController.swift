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
    @IBOutlet weak var addGeneratorButton: NSButton!
    @IBOutlet weak var deleteGeneratorButton: NSButton!
    @IBOutlet weak var generatorTableView: NSTableView!
    
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var moveUpButton: NSButton!
    @IBOutlet weak var moveDownButton: NSButton!
    
    
    var separators: Results<Separator> = try! Realm().objects(Separator).sorted("title")
    var allSourceBricks: Results<Brick> = try! Realm().objects(Brick).sorted("title")
    var sourceBricks: Results<Brick> = try! Realm().objects(Brick).sorted("title")
    var generators: Results<Generator> = try! Realm().objects(Generator).sorted("title")
    
    var isReloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI:", name: "AddDelete", object: nil)
        
        updateUI(self)
    }
    
    func selectedGenerator() -> Generator {
//        let index = generatorTableView.selectedRow
//        NSLog("Index ist \(index)")
//        if index == -1 {
            return currentGenerator()
//        }
//        return generators[index]
    }
    
    func currentGenerator() -> Generator {
        let realm = try! Realm()
        let obj = realm.objects(Generator).filter("isDefault = true").first
        if obj != nil {
            return obj!
        }
        let newObj = Generator()
        newObj.title = "Default"
        newObj.isDefault = true
        try! realm.write { realm.add(newObj) }
        return newObj
    }
    
    func updateUI(sender: AnyObject){
        self.isReloading = true
        bricksSourceTableView.reloadData()
        bricksDestinationTableView.reloadData()
        updateHeaderFooterSeparator(selectedGenerator())
        headerTextView.string = selectedGenerator().headerText
        footerTextView.string = selectedGenerator().footerText
        
//        generatorTableView.selectRowIndexes(NSIndexSet(index: generators.indexOf(currentGenerator())!), byExtendingSelection: false)
        
        self.isReloading = false
        
    }
    
    func updateHeaderFooterSeparator(generator: Generator){
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

    @IBAction func addGeneratorButton(sender: AnyObject) {
        let realm = try! Realm()
        let generator = Generator()
        generator.title = "New"
        try! realm.write{
            realm.add(generator)
        }
        if let newRowIndex = self.generators.indexOf(generator){
            self.generatorTableView.insertRowsAtIndexes(NSIndexSet(index: newRowIndex), withAnimation: NSTableViewAnimationOptions.EffectFade)
            self.generatorTableView.selectRowIndexes(NSIndexSet(index: newRowIndex), byExtendingSelection:false)
            self.generatorTableView.scrollRowToVisible(newRowIndex)
        }
    }
    
    @IBAction func removeGeneratorButton(sender: AnyObject) {
        let realm = try! Realm()
        let generator = self.currentGenerator()
        generatorTableView.removeRowsAtIndexes(generatorTableView.selectedRowIndexes, withAnimation: NSTableViewAnimationOptions.EffectFade)
        try! realm.write{
            realm.delete(generator)
        }
        try! realm.write{
            self.generators[0].isDefault = true
        }
        updateUI(self)
    }
    
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
            NSLog("\(index)")
            bricksToMove.append(sourceBricks[index])
        }
        let realm = try! Realm()
        let indexesToInsert = NSMutableIndexSet()
        for brick in bricksToMove {
            let generatorBrick = GeneratorBrick()
            generatorBrick.brick = brick
            try! realm.write{
                realm.add(generatorBrick)
                self.currentGenerator().generatorBricks.append(generatorBrick)
            }
            if let index = currentGenerator().generatorBricks.indexOf(generatorBrick){
                indexesToInsert.addIndex(index)
            }
        }

//        bricksSourceTableView.removeRowsAtIndexes(bricksSourceTableView.selectedRowIndexes, withAnimation: NSTableViewAnimationOptions.EffectFade)
        bricksDestinationTableView.insertRowsAtIndexes(indexesToInsert, withAnimation: NSTableViewAnimationOptions.EffectFade)
        
        self.bricksDestinationTableView.scrollRowToVisible(indexesToInsert.maxElement()!)
    }

    @IBAction func removeButton(sender: AnyObject) {
        var bricksToMove = [Brick]()
        var generatorBricksToMove = [GeneratorBrick]()
        for index in bricksDestinationTableView.selectedRowIndexes {
            generatorBricksToMove.append(selectedGenerator().generatorBricks[index])
            if let brick = selectedGenerator().generatorBricks[index].brick{
                bricksToMove.append(brick)
            }
        }
        let realm = try! Realm()
        try! realm.write {
            for generatorBrick in generatorBricksToMove {
                realm.delete(generatorBrick)
            }
        }
        
        let indexesToInsert = NSMutableIndexSet()
        for brick in bricksToMove {
            if let index = sourceBricks.indexOf(brick) {
                indexesToInsert.addIndex(index)
            }
        }
        bricksDestinationTableView.removeRowsAtIndexes(bricksDestinationTableView.selectedRowIndexes, withAnimation: NSTableViewAnimationOptions.EffectFade)
//        bricksSourceTableView.insertRowsAtIndexes(indexesToInsert, withAnimation: NSTableViewAnimationOptions.EffectFade)
    }
    
    @IBAction func moveUpButton(sender: AnyObject) {
        for index in bricksDestinationTableView.selectedRowIndexes {
            if index > 0 && index < selectedGenerator().generatorBricks.count {
                try! Realm().write{
                    self.selectedGenerator().generatorBricks.move(from: index, to: index-1)
                }
                bricksDestinationTableView.moveRowAtIndex(index, toIndex: index - 1)
            }
        }
    }
    
    @IBAction func moveDownButton(sender: AnyObject) {
        for index in bricksDestinationTableView.selectedRowIndexes.reverse() {
            if index >= 0 && index < selectedGenerator().generatorBricks.count-1 {
                try! Realm().write{
                    self.selectedGenerator().generatorBricks.move(from: index, to: index + 1)
                }
                bricksDestinationTableView.moveRowAtIndex(index, toIndex: index + 1)
            }
        }
    }
    
    @IBAction func generateButton(sender: AnyObject) {
        var string = String()
        string += headerTextView.string!
        if let separator = selectedGenerator().headerSeparator {
            string += separator.text
        }
        for generatorBrick in selectedGenerator().generatorBricks {
            if let brick = generatorBrick.brick{
                string += brick.text
                if let separator = generatorBrick.separator{
                    string += separator.text
                }
            }
        }
        if let separator = selectedGenerator().footerSeparator {
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
            self.selectedGenerator().headerText = self.headerTextView.string!
            self.selectedGenerator().footerText = self.footerTextView.string!
        }
    }
}

extension GeneratorViewController: NSTableViewDelegate {

    @IBAction func endEditingText(sender: AnyObject){
        let textField = sender as! NSTextField
        let index = generatorTableView.rowForView(textField)
        let generator = generators[index]
        try! Realm().write{
            generator.title = textField.stringValue
        }
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let tableView = notification.object {
            if tableView.isEqual(bricksDestinationTableView){
                let buttonsEnabled = (tableView.selectedRowIndexes.count > 0)
                removeButton.enabled = buttonsEnabled
                moveUpButton.enabled = buttonsEnabled
                moveDownButton.enabled = buttonsEnabled
            }
            if tableView.isEqual(bricksSourceTableView){
                addButton.enabled = (tableView.selectedRowIndexes.count > 0)
            }
            if tableView.isEqual(generatorTableView){
                if tableView.selectedRowIndexes.count > 0 {
                    let generators = try! Realm().objects(Generator).filter("isDefault = true")
                    let newDefaultGenerator = self.generators[tableView.selectedRow]
                    try! Realm().write{
                        for generator in generators {
                            generator.isDefault = false
                        }
                        newDefaultGenerator.isDefault = true
                    }
                    updateUI(self)
                }
            }
            let buttonsEnabled = (tableView.selectedRowIndexes.count > 0 && tableView.numberOfRows > 1)
            deleteGeneratorButton.enabled = buttonsEnabled
        }
    }
}

extension GeneratorViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        if aTableView.isEqual(bricksSourceTableView) {
            return self.sourceBricks.count
        }
        if aTableView.isEqual(bricksDestinationTableView) {
            return selectedGenerator().generatorBricks.count
        }
        if aTableView.isEqual(generatorTableView) {
            return self.generators.count
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
            if let brick = selectedGenerator().generatorBricks[row].brick{
                (cellView as! GeneratorDestinationTableCellView).textField!.stringValue = brick.title
            }
            //Combobox für Separators mit daten füllen
            let cb = (cellView as! GeneratorDestinationTableCellView).comboBox
            cb.removeAllItems()
            cb.addItemWithObjectValue("None")
            for separator in separators {
                cb.addItemWithObjectValue(separator.title)
            }
            //Richtigen Separator in der Combobox auswählen
            if let separator = selectedGenerator().generatorBricks[row].separator {
                if let index = separators.indexOf(separator) {
                    cb.selectItemAtIndex(index + 1)
                }
            } else {
                cb.selectItemAtIndex(0)
            }
        }
        if tableView.isEqual(generatorTableView) {
            let generator = self.generators[row]
            (cellView as! NSTableCellView).textField!.stringValue = generator.title
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
                    self.selectedGenerator().headerSeparator = separator
                }
                
            } else if cb.isEqual(footerSeparatorComboBox) && isReloading == false {
                var separator: Separator? = nil
                
                if cb.indexOfSelectedItem > 0 {
                    separator = separators[cb.indexOfSelectedItem - 1]
                }
                
                try! Realm().write{
                    self.selectedGenerator().footerSeparator = separator
                }
            } else {
                let index = bricksDestinationTableView.rowForView(cb)
                if index >= 0 && index < selectedGenerator().generatorBricks.count {
                    let generatorBrick = selectedGenerator().generatorBricks[index]
                    var separator: Separator? = nil
                    if cb.indexOfSelectedItem > 0 {
                        separator = separators[cb.indexOfSelectedItem - 1]
                    }
                    try! Realm().write{
                        generatorBrick.separator = separator
                    }
                    
                }
            }
        }
    }
}













