//
//  String+Extension.swift
//  SJExpandableTableView
//
//  Created by sabrina on 2020/12/1.
//  Copyright © 2020 sabrina. All rights reserved.
//

import UIKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    var hasHTMLFormat: Bool {
        let htmlFormat1 = "*<*>*</*>"
        let htmlFormat2 = "*<*/>*"
        let predicate = NSPredicate(format: "SELF like[cd] %@ OR SELF like[cd] %@", htmlFormat1, htmlFormat2)
        return predicate.evaluate(with: self)
    }
}


enum Log {
    static func debug<T>(_ message:T, file:String = #file, function:String = #function, line:Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("\n🐞 [DEBUG] [\(fileName)][\(function)][\(line)] : \(message)")
    }
    
    static func info<T>(_ message:T, file:String = #file, function:String = #function, line:Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("\n✅ [INFO] [\(fileName)][\(function)][\(line)] : \(message)")
    }
    
    static func error<T>(_ message:T, file:String = #file, function:String = #function, line:Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("\n‼️ [ERROR] [\(fileName)][\(function)][\(line)] : \(message)")
    }
    
    static func warning<T>(_ message:T, file:String = #file, function:String = #function, line:Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("\n⚠️ [WARNING] [\(fileName)][\(function)][\(line)] : \(message)")
    }
}

