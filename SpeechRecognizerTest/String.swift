//
//  String.swift
//  SpeechRecognizerTest
//
//  Created by T Shibuya on 2018/02/21.
//  Copyright © 2018年 T S. All rights reserved.
//

import Foundation
extension String {
    func toKatakana() -> String {
        var str = ""
        
        for c in unicodeScalars {
            if c.value >= 0x3041 && c.value <= 0x3096 {
                str += String(describing: UnicodeScalar(c.value + 96)!)
            } else {
                str += String(c)
            }
        }
        
        return str
    }
    
    func toHiragana() -> String {
        var str = ""
        
        for c in unicodeScalars {
            if c.value >= 0x30A1 && c.value <= 0x30F6 {
                str += String(describing: UnicodeScalar(c.value - 96)!)
            } else {
                str += String(c)
            }
        }
        
        return str
    }
    func length() -> Int{
        return unicodeScalars.count
    }
}
