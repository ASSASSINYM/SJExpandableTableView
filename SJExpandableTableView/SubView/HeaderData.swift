//
//  HeaderData.swift
//  SJExpandableTableView
//
//  Created by sabrina on 2020/12/1.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

struct HeaderData {
    let text:String
    var color:UIColor = UIColor.black
    var align:NSTextAlignment = .center
}

struct ContentData {
    let text:ContentText
    var color:UIColor = .black
    var align:NSTextAlignment = .center
    var showAutoHeight:Bool = false
    
    init(text:ContentText, color:UIColor = UIColor.black, align:NSTextAlignment = .center, autoHeight:Bool = false) {
        self.color = color
        self.align = align
        self.showAutoHeight = autoHeight
        switch text {
        case .attributed(let attrStr):
            if attrStr.string.hasHTMLFormat, let attr = attrStr.string.htmlToAttributedString {
                self.text = ContentText.attributed(attr)
            }else{
                self.text = text
            }
        default:
            self.text = text
        }
    }
    
    enum ContentText {
        case string(String)
        case attributed(NSAttributedString)
    }
}

struct BindData {
    var onBind: BindType?
    mutating func bind(to tb:SJExpandableTableView) {
        onBind = tb.getBind()
    }
}
