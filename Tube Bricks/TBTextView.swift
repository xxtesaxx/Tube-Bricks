//
//  TBTextView.swift
//  Tube Bricks
//
//  Created by Jan Thielemann on 10.11.15.
//  Copyright © 2015 Jan Thielemann. All rights reserved.
//

import Cocoa

class TBTextView: NSTextView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func paste(sender: AnyObject?) {
        let pb = NSPasteboard.generalPasteboard()
        if let items  = pb.readObjectsForClasses([NSClassFromString(NSAttributedString.className())!, NSClassFromString(NSString.className())!], options: nil) {
            if let item = items.last {
                if item.isKindOfClass(NSClassFromString(NSAttributedString.className())!){
                    if let string = item as? NSAttributedString {
                        let mutableString = string.mutableCopy() as! NSMutableAttributedString
                        var offset = 0
                        string.enumerateAttribute(NSLinkAttributeName, inRange: NSMakeRange(0, string.length), options: .LongestEffectiveRangeNotRequired, usingBlock: { attribute, range, stop -> Void in
                            if attribute != nil {
                                if let url = attribute as? NSURL {
                                    mutableString.replaceCharactersInRange(NSMakeRange(range.location + offset, range.length), withAttributedString: NSAttributedString(string: url.absoluteString))
                                    offset += url.absoluteString.characters.count - string.attributedSubstringFromRange(range).string.characters.count
                                    
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
