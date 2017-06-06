//
//  SeparatorsViewController.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 29.10.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa
import RealmSwift

class SeparatorsViewController: NSViewController {
    var allSeparators: Results<Separator> = try! Realm().objects(Separator).sorted("title")
    var separators: Results<Separator> = try! Realm().objects(Separator).sorted("title")
    var generator: Generator?
    var dataFilePath: String?
    
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var defaultCheckbox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func selectedSeparator() -> Separator? {
        let selectedRow = self.tableView.selectedRow;
        if selectedRow >= 0 && selectedRow < separators.count {
            return self.separators[selectedRow]
        }
        return nil
    }
    
    func updateDetailInfo(_ data: Separator?) {
        var title = ""
        var text = ""
        var isDefault = false
        if let separator = data {
            title = separator.title
            text = separator.text
            isDefault = separator.isDefault
        }
        
        self.textField.stringValue = title
        self.textView.string = text
        self.defaultCheckbox.state = buttonStateForBool(isDefault)
        
    }
    
    func reloadRow(_ row: Int) {
        let indexSet = IndexSet(integer: row)
        let columnSet = IndexSet(integer: 0)
        self.tableView.reloadData(forRowIndexes: indexSet, columnIndexes: columnSet)
    }
    
    func isDefaultCheckboxChecked() -> Bool {
        if self.defaultCheckbox.state == NSOnState {
            return true
        } else {
            return false
        }
    }
    
    func buttonStateForBool(_ value: Bool) -> Int {
        if value {
            return NSOnState
        }else {
            return NSOffState
        }
    }
    
}

// MARK: IBActions
extension SeparatorsViewController{
    
    func sendAddDeleteNotification(){
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "AddDelete"), object: nil))
    }
    
    @IBAction func search(_ sender: AnyObject) {
        let searchField = sender as! NSSearchField
        tableView.deselectRow(tableView.selectedRow)
        if searchField.stringValue.isEmpty {
            separators = allSeparators
            tableView.reloadData()
        }else{
            separators = allSeparators.filter("title contains[c] %a", searchField.stringValue)
            tableView.reloadData()
        }
        
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        if let selectedData = selectedSeparator() {
            let selectedRow = separators.indexOf(selectedData)

            let realm = try! Realm()
            if isDefaultCheckboxChecked() {
                let defaults = realm.objects(Separator).filter("isDefault = true")
                try! realm.write{
                    for defaultSeparator in defaults {
                        defaultSeparator.isDefault = false
                    }
                }
            }
            
            try! realm.write{
                selectedData.title = self.textField.stringValue
                selectedData.text = self.textView.string!
                selectedData.isDefault = self.isDefaultCheckboxChecked()
            }
            
            let newSelectedRow = separators.indexOf(selectedData)
            self.tableView.moveRowAtIndex(selectedRow!, toIndex: newSelectedRow!)
            self.reloadRow(newSelectedRow!)
        }
        sendAddDeleteNotification()
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        let newData = Separator(value: ["title": "New Separator", "text": ""])
        let realm = try! Realm()
        try! realm.write{
            realm.add(newData)
            if let newRowIndex = self.separators.indexOf(newData){
                self.tableView.insertRowsAtIndexes(NSIndexSet(index: newRowIndex), withAnimation: NSTableViewAnimationOptions.EffectFade)
                self.tableView.selectRowIndexes(NSIndexSet(index: newRowIndex), byExtendingSelection:false)
                self.tableView.scrollRowToVisible(newRowIndex)
            }
        }
        sendAddDeleteNotification()
    }
    @IBAction func deleteButtonPressed(_ sender: AnyObject) {
        if let selectedSeparator = selectedSeparator() {
            let realm = try! Realm()
            try! realm.write{
                realm.delete(selectedSeparator)
                self.tableView.removeRowsAtIndexes(NSIndexSet(index:self.tableView.selectedRow),
                    withAnimation: NSTableViewAnimationOptions.EffectFade)
                self.updateDetailInfo(nil)
            }
            sendAddDeleteNotification()
        }
    }
}

// MARK: - NSTableViewDataSource
extension SeparatorsViewController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        return Int(self.separators.count)
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView: NSTableCellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        let sep = self.separators[row]
        cellView.textField!.stringValue = sep.title
        
        return cellView
    }
}

// MARK: - NSTableViewDelegate
extension SeparatorsViewController: NSTableViewDelegate {
    
    @IBAction func endEditingText(_ sender: AnyObject){
        let textField = sender as! NSTextField
        let index = tableView.row(for: textField)
        if index >= 0 {
            let separator = separators[index]
            try! Realm().write{
                separator.title = textField.stringValue
            }
            if let newIndex = separators.indexOf(separator) {
                if index != newIndex {
                    tableView.moveRowAtIndex(index, toIndex: newIndex)
                }
            }
            updateDetailInfo(separator)
            sendAddDeleteNotification()
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedData = selectedSeparator()
        updateDetailInfo(selectedData)
        let buttonsEnabled = (selectedData != nil)
        textField.isEnabled = buttonsEnabled
        textView.isEditable = buttonsEnabled
        textView.isSelectable = buttonsEnabled
        deleteButton.isEnabled = buttonsEnabled
        saveButton.isEnabled = buttonsEnabled
        defaultCheckbox.isEnabled = buttonsEnabled
    }
}























