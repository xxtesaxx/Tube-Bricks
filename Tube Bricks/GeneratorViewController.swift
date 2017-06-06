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
    
    
    var separators: Results<Separator> = try! Realm().objects(Separator.self).sorted(byKeyPath: "title")
    var allSourceBricks: Results<Brick> = try! Realm().objects(Brick.self).sorted(byKeyPath: "title")
    var sourceBricks: Results<Brick> = try! Realm().objects(Brick.self).sorted(byKeyPath: "title")
    var generators: Results<Generator> = try! Realm().objects(Generator.self).sorted(byKeyPath: "title")
    
    var isReloading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GeneratorViewController.updateUI(_:)), name: NSNotification.Name(rawValue: "AddDelete"), object: nil)
        
        updateUI(self)
        
        bricksDestinationTableView.register(forDraggedTypes: ["jan.le.mann.generatorbricks"])
        bricksDestinationTableView.register(forDraggedTypes: ["jan.le.mann.bricks"])
    }
    
    func currentGenerator() -> Generator {
        let realm = try! Realm()
        let obj = realm.objects(Generator.self).filter("isDefault = true").first
        if obj != nil {
            return obj!
        }
        let newObj = Generator()
        newObj.title = "Default"
        newObj.isDefault = true
        try! realm.write { realm.add(newObj) }
        return newObj
    }
    
    func updateUI(_ sender: AnyObject){
        self.isReloading = true
        bricksSourceTableView.deselectAll(self)
        bricksSourceTableView.reloadData()
        bricksDestinationTableView.deselectAll(self)
        bricksDestinationTableView.reloadData()
        updateHeaderFooterSeparator(currentGenerator())
        headerTextView.string = currentGenerator().headerText
        footerTextView.string = currentGenerator().footerText
        
        if let index = generators.index(of: currentGenerator()) {
            generatorTableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        }
        
        self.isReloading = false
    }
    
    func updateHeaderFooterSeparator(_ generator: Generator){
        headerSeparatorComboBox.removeAllItems()
        headerSeparatorComboBox.addItem(withObjectValue: "None")
        for (_, value) in separators.enumerated() {
            headerSeparatorComboBox.addItem(withObjectValue: value.title)
        }
        if let headerSeparator = generator.headerSeparator {
            let index = separators.index(of: headerSeparator)! + 1
            headerSeparatorComboBox.selectItem(at: index)
        }else {
            headerSeparatorComboBox.selectItem(at: 0)
        }
        
        footerSeparatorComboBox.removeAllItems()
        footerSeparatorComboBox.addItem(withObjectValue: "None")
        for (_, value) in separators.enumerated() {
            footerSeparatorComboBox.addItem(withObjectValue: value.title)
        }
        
        if let footerSeparator = generator.footerSeparator {
            let index = separators.index(of: footerSeparator)! + 1
            footerSeparatorComboBox.selectItem(at: index)
        }else {
            footerSeparatorComboBox.selectItem(at: 0)
        }
    }
}

// MARK: - IBActions

extension GeneratorViewController {

    @IBAction func addGeneratorButton(_ sender: AnyObject) {
        let realm = try! Realm()
        let generator = Generator()
        generator.title = "New"
        try! realm.write{
            realm.add(generator)
        }
        if let newRowIndex = self.generators.index(of: generator){
            self.generatorTableView.insertRows(at: IndexSet(integer: newRowIndex), withAnimation: .effectFade)
            self.generatorTableView.selectRowIndexes(IndexSet(integer: newRowIndex), byExtendingSelection:false)
            self.generatorTableView.scrollRowToVisible(newRowIndex)
        }
    }
    
    @IBAction func removeGeneratorButton(_ sender: AnyObject) {
        if generators.count < 2 {
            return
        }
        
        let realm = try! Realm()
        let generator = self.currentGenerator()
        generatorTableView.removeRows(at: generatorTableView.selectedRowIndexes, withAnimation: NSTableViewAnimationOptions.effectFade)
        try! realm.write{
            for generatorBrick in generator.generatorBricks {
                realm.delete(generatorBrick)
            }
            realm.delete(generator)
        }
        try! realm.write{
            self.generators[0].isDefault = true
        }
        updateUI(self)
    }
    
    @IBAction func search(_ sender: AnyObject) {
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
    
    
    @IBAction func addButton(_ sender: AnyObject) {
        var bricksToMove = [Brick]()
        for index in bricksSourceTableView.selectedRowIndexes {
            bricksToMove.append(sourceBricks[index])
        }
        let realm = try! Realm()
        let indexesToInsert = NSMutableIndexSet()
        let defaultSeparator = realm.objects(Separator.self).filter("isDefault = true").first
        for brick in bricksToMove {
            let generatorBrick = GeneratorBrick()
            generatorBrick.brick = brick
            generatorBrick.separator = defaultSeparator
            try! realm.write{
                realm.add(generatorBrick)
                self.currentGenerator().generatorBricks.append(generatorBrick)
            }
            if let index = currentGenerator().generatorBricks.index(of: generatorBrick){
                indexesToInsert.add(index)
            }
        }

        bricksDestinationTableView.insertRows(at: indexesToInsert as IndexSet, withAnimation: NSTableViewAnimationOptions.effectFade)
        
        self.bricksDestinationTableView.scrollRowToVisible(indexesToInsert.max()!)
    }

    @IBAction func removeButton(_ sender: AnyObject) {
        var bricksToMove = [Brick]()
        var generatorBricksToMove = [GeneratorBrick]()
        for index in bricksDestinationTableView.selectedRowIndexes {
            generatorBricksToMove.append(currentGenerator().generatorBricks[index])
            if let brick = currentGenerator().generatorBricks[index].brick{
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
            if let index = sourceBricks.index(of: brick) {
                indexesToInsert.add(index)
            }
        }
        bricksDestinationTableView.removeRows(at: bricksDestinationTableView.selectedRowIndexes, withAnimation: NSTableViewAnimationOptions.effectFade)

    }
    
    @IBAction func moveUpButton(_ sender: AnyObject) {
        for index in bricksDestinationTableView.selectedRowIndexes {
            if index > 0 && index < currentGenerator().generatorBricks.count {
                try! Realm().write{
                    self.currentGenerator().generatorBricks.move(from: index, to: index-1)
                }
                bricksDestinationTableView.moveRow(at: index, to: index - 1)
            }
        }
    }
    
    @IBAction func moveDownButton(_ sender: AnyObject) {
        for index in bricksDestinationTableView.selectedRowIndexes.reversed() {
            if index >= 0 && index < currentGenerator().generatorBricks.count-1 {
                try! Realm().write{
                    self.currentGenerator().generatorBricks.move(from: index, to: index + 1)
                }
                bricksDestinationTableView.moveRow(at: index, to: index + 1)
            }
        }
    }
    
    @IBAction func generateButton(_ sender: AnyObject) {
        var string = String()
        string += headerTextView.string!
        if let separator = currentGenerator().headerSeparator {
            string += separator.text
        }
        for generatorBrick in currentGenerator().generatorBricks {
            if let brick = generatorBrick.brick{
                string += brick.text
                if let separator = generatorBrick.separator{
                    string += separator.text
                }
            }
        }
        if let separator = currentGenerator().footerSeparator {
            string += separator.text
        }
        string += footerTextView.string!
        let pasteboard = NSPasteboard.general()
        pasteboard.clearContents()
        pasteboard.writeObjects([string as NSPasteboardWriting])
    }
}

// MARK: - NSTextViewDelegate

extension GeneratorViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        if let textView = notification.object as? NSTextView {
            if textView.isEqual(headerTextView){
                try! Realm().write{
                    self.currentGenerator().headerText = textView.string!
                }
            }
            if textView.isEqual(footerTextView){
                try! Realm().write{
                    self.currentGenerator().footerText = textView.string!
                }
            }
        }
    }
}

// MARK: - NSTableViewDelegate

extension GeneratorViewController: NSTableViewDelegate {

    @IBAction func endEditingText(_ sender: AnyObject){
        let textField = sender as! NSTextField
        let index = generatorTableView.row(for: textField)
        if index >= 0 {
            let generator = generators[index]
            try! Realm().write{
                generator.title = textField.stringValue
            }
            if let newIndex = generators.index(of: generator) {
                if index != newIndex {
                    generatorTableView.moveRow(at: index, to: newIndex)
                }
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableView = notification.object as? NSTableView {
            if tableView.isEqual(bricksDestinationTableView){
                let buttonsEnabled = tableView.selectedRowIndexes.count > 0
                removeButton.isEnabled = buttonsEnabled
                moveUpButton.isEnabled = buttonsEnabled
                moveDownButton.isEnabled = buttonsEnabled
            }
            if tableView.isEqual(bricksSourceTableView){
                addButton.isEnabled = tableView.selectedRowIndexes.count > 0
            }
            if tableView.isEqual(generatorTableView){
                if tableView.selectedRowIndexes.count > 0 {
                    let generators = try! Realm().objects(Generator.self).filter("isDefault = true")
                    let newDefaultGenerator = self.generators[tableView.selectedRow]
                    try! Realm().write{
                        for generator in generators {
                            generator.isDefault = false
                        }
                        newDefaultGenerator.isDefault = true
                    }
                }
                let buttonsEnabled = ((tableView as AnyObject).selectedRowIndexes.count > 0 && (tableView as AnyObject).numberOfRows > 1)
                deleteGeneratorButton.isEnabled = buttonsEnabled
                updateUI(self)
            }
        }
    }
}

// MARK: - NSTableViewDataSource

extension GeneratorViewController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        if aTableView.isEqual(bricksSourceTableView) {
            return self.sourceBricks.count
        }
        if aTableView.isEqual(bricksDestinationTableView) {
            return currentGenerator().generatorBricks.count
        }
        if aTableView.isEqual(generatorTableView) {
            return self.generators.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: self)
        
        if tableView.isEqual(bricksSourceTableView) {
            let brick = self.sourceBricks[row]
            (cellView as! NSTableCellView).textField!.stringValue = brick.title
        }
        if tableView.isEqual(bricksDestinationTableView) {
            if let brick = currentGenerator().generatorBricks[row].brick{
                (cellView as! GeneratorDestinationTableCellView).textField!.stringValue = brick.title
            }
            //Combobox für Separators mit daten füllen
            let cb = (cellView as! GeneratorDestinationTableCellView).comboBox
            cb?.removeAllItems()
            cb?.addItem(withObjectValue: "None")
            for separator in separators {
                cb?.addItem(withObjectValue: separator.title)
            }
            //Richtigen Separator in der Combobox auswählen
            if let separator = currentGenerator().generatorBricks[row].separator {
                if let index = separators.index(of: separator) {
                    cb?.selectItem(at: index + 1)
                }
            } else {
                cb?.selectItem(at: 0)
            }
        }
        if tableView.isEqual(generatorTableView) {
            let generator = self.generators[row]
            (cellView as! NSTableCellView).textField!.stringValue = generator.title
        }
        return cellView
    }
    
    
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if tableView.isEqual(bricksDestinationTableView){
            let item = NSPasteboardItem()
            item.setString(String(row), forType: "jan.le.mann.generatorbricks")
            return item
        }
        if tableView.isEqual(bricksSourceTableView){
            let item = NSPasteboardItem()
            item.setString(String(row), forType: "jan.le.mann.bricks")
            return item
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if tableView.isEqual(bricksDestinationTableView){
            if dropOperation == .above {
                return .move
            }
        }
        return NSDragOperation()
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        if tableView.isEqual(bricksDestinationTableView){
            var oldIndexes = [Int]()
            var newIndexes = [Int]()
            info.enumerateDraggingItems(options: .clearNonenumeratedImages, for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
                if let item = ($0.0.item as? NSPasteboardItem) {
                    if let index = item.string(forType: "jan.le.mann.generatorbricks") {
                        if let indexInt = Int(index) {
                            oldIndexes.append(indexInt)
                        }
                    }
                    if let index = item.string(forType: "jan.le.mann.bricks") {
                        if let indexInt = Int(index) {
                            newIndexes.append(indexInt)
                        }
                    }
                }
            }

            var oldIndexOffset = 0
            var newIndexOffset = 0
        
            let realm = try! Realm()
            let generator = currentGenerator()
            tableView.beginUpdates()
            for oldIndex in oldIndexes {
                if oldIndex < row {
                    try! Realm().write{
                        generator.generatorBricks.move(from: oldIndex + oldIndexOffset, to: row - 1)
                    }
                    tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                    oldIndexOffset -= 1
                } else {
                    try! realm.write{
                        generator.generatorBricks.move(from: oldIndex, to: row + newIndexOffset)
                    }
                    tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                    newIndexOffset += 1
                }
            }
            
            for newIndex in newIndexes.reversed() {
                let brick = sourceBricks[newIndex]
                let generatorBrick = GeneratorBrick()
                generatorBrick.brick = brick
                try! realm.write{
                    realm.add(generatorBrick)
                    generator.generatorBricks.insert(generatorBrick, at: row)
                }
                tableView.insertRows(at: IndexSet(integer: row), withAnimation: .effectFade)
            }
            tableView.endUpdates()
        
            return true
        }
        return false
    }
}

// MARK: - NSComboBoxDelegate

extension GeneratorViewController: NSComboBoxDelegate {
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let cb = notification.object as? NSComboBox{
            if cb.isEqual(headerSeparatorComboBox) && isReloading == false {
                var separator: Separator? = nil
            
                if cb.indexOfSelectedItem > 0 {
                    separator = separators[cb.indexOfSelectedItem - 1]
                }
                
                try! Realm().write{
                    self.currentGenerator().headerSeparator = separator
                }
                
            } else if cb.isEqual(footerSeparatorComboBox) && isReloading == false {
                var separator: Separator? = nil
                
                if cb.indexOfSelectedItem > 0 {
                    separator = separators[cb.indexOfSelectedItem - 1]
                }
                
                try! Realm().write{
                    self.currentGenerator().footerSeparator = separator
                }
            } else {
                let index = bricksDestinationTableView.row(for: cb)
                if index >= 0 && index < currentGenerator().generatorBricks.count {
                    let generatorBrick = currentGenerator().generatorBricks[index]
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













