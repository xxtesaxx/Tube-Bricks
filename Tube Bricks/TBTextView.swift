//
//  TBTextView.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 10.11.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa

class TBTextView: NSTextView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func paste(_ sender: Any?) {
        let pb = NSPasteboard.general()
        if let items  = pb.readObjects(forClasses: [NSClassFromString(NSAttributedString.className())!, NSClassFromString(NSString.className())!], options: nil) {
            if let item = items.last {
                if (item as AnyObject).isKind(of: NSClassFromString(NSAttributedString.className())!){
                    if let string = item as? NSAttributedString {
                        let mutableString = string.mutableCopy() as! NSMutableAttributedString
                        var offset = 0
                        string.enumerateAttribute(NSLinkAttributeName, in: NSMakeRange(0, string.length), options: .longestEffectiveRangeNotRequired, using: { attribute, range, stop -> Void in
                            if attribute != nil {
                                if let url = attribute as? URL {
                                    mutableString.replaceCharacters(in: NSMakeRange(range.location + offset, range.length), with: NSAttributedString(string: url.absoluteString))
                                    offset += url.absoluteString.characters.count - string.attributedSubstring(from: range).string.characters.count
                                    
                                }
                            }
                        })
                        self.insertText(mutableString.string, replacementRange: self.selectedRange())
                        return
                    }
                }
            }
        }
        super.paste(sender)
    }
}
