//
//  furegana.swift
//  SpeechRecognizerTest
//
//  Created by T Shibuya on 2018/02/22.
//  Copyright © 2018年 T S. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash
class furigana{
    public var message:String = ""
    func test(){
        //Alamofire.request(https:"//jlp.yahooapis.jp/FuriganaService/V1/furigana")
        //https://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=dj00aiZpPTI5R2xhNE1LeDlndSZzPWNvbnN1bWVyc2VjcmV0Jng9YjA-&grade=1&sentence=漢字かな交じり文にふりがなを振ること%E3%80%82
        var url:String = "https://jlp.yahooapis.jp/FuriganaService/V1/furigana"
        url += "?appid=dj00aiZpPTI5R2xhNE1LeDlndSZzPWNvbnN1bWVyc2VjcmV0Jng9YjA-"//yahooのデベロッパーID
        url += "&grade=1"//全部ルビをふる
        //let msg = "漢字や平仮名が混ざっていても振り仮名を入力してくれる"
        let msg = "https://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=dj00aiZpPTI5R2xhNE1LeDlndSZzPWNvbnN1bWVyc2VjcmV0Jng9YjA-&grade=1&sentence=%e6%bc%a2%e5%ad%97%e3%81%8b%e3%81%aa%e4%ba%a4%e3%81%98%e3%82%8a%e6%96%87%e3%81%ab%e3%81%b5%e3%82%8a%e3%81%8c%e3%81%aa%e3%82%92%e6%8c%af%e3%82%8b%e3%81%93%e3%81%a8%e3%80%82"
        url += "&sentence=" + msg
        print("test   \(url)")
        Alamofire.request(msg, method: .get).responseString(completionHandler: { response in
            //print(response.result.value)
            self.message = response.result.value!
            var xml:XMLIndexer? = nil
            DispatchQueue.global().async {
                xml = SWXMLHash.parse(response.result.value!)
            }
            // dataを取得するまで待ちます
            self.wait( { return xml == nil } ) {
                print("show xml data")
                print(xml!["ResultSet"]["Result"]["WordList"]["Word"][0]["Furigana"].element!.text)
            }
            

        })
        
        
    }
    /// 条件をクリアするまで待ちます
    ///
    /// - Parameters:
    ///   - waitContinuation: 待機条件
    ///   - compleation: 通過後の処理
    func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
        var wait = waitContinuation()
        // 0.01秒周期で待機条件をクリアするまで待ちます。
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while wait {
                DispatchQueue.main.async {
                    wait = waitContinuation()
                    semaphore.signal()
                }
                semaphore.wait()
                Thread.sleep(forTimeInterval: 0.01)
            }
            // 待機条件をクリアしたので通過後の処理を行います。
            DispatchQueue.main.async {
                compleation()
            }
        }
    }
}
