//
//  pokemon.swift
//  SpeechRecognizerTest
//
//  Created by T Shibuya on 2018/02/21.
//  Copyright © 2018年 T S. All rights reserved.
//

import Foundation
import RealmSwift

//1,フシギダネ,くさ,どく,しんりょく,x,ようりょくそ,45,49,49,65,65,45,6.9
class Pokemon: Object {
 @objc dynamic var id:Int = 0
 @objc dynamic var indexnum:String = ""//図鑑番号とか画像名とのリンク用
 @objc dynamic var name = ""
 @objc dynamic var type1 = ""
 @objc dynamic var type2:String?
 @objc dynamic var ability1 = ""
 @objc dynamic var ability2:String?
 @objc dynamic var ability3:String?
 @objc dynamic var bsHP:Int = 0
 @objc dynamic var bsA:Int = 0
 @objc dynamic var bsB:Int = 0
 @objc dynamic var bsC:Int = 0
 @objc dynamic var bsD:Int = 0
 @objc dynamic var bsS:Int = 0
 @objc dynamic var weight:Double = 0.0
 //@objc dynamic var type1: Type!
 //@objc dynamic var type2: Type?
 
 }
