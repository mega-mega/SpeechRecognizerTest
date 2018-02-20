

import Foundation
class CSVpokedata: NSObject{
    //private let filename = "CSVpokedata"
    
    class func loadCSV(filename:String) -> [String]{
        //CSVファイルを格納するための配列を作成
        var csvArray:[String] = []
        //CSVファイルの読み込み
        let csvBundle = Bundle.main.path(forResource: filename, ofType: "csv")
        
        do {
            //csvBundleのパスを読み込み、UTF8に文字コード変換して、NSStringに格納
            let csvData = try String(contentsOfFile: csvBundle!,encoding: String.Encoding.utf8)
            //改行コードが"\r"で行なわれている場合は"\n"に変更する
            let lineChange = csvData.replacingOccurrences(of: "\r", with: "\n")
            //"\n"の改行コードで区切って、配列csvArrayに格納する
            csvArray = lineChange.components(separatedBy: "\n")
        }
        catch {
            print("エラー")
        }
        return csvArray
    }
    //718c,ジガルデ完,ドラゴン,じめん,スワームチェンジ,x,,216,100,121,91,95,85,708
    class func loadPKdata(pkname:String)->(num:String,name:String,type:[String],ability:[String],BS:[Int],weight:Double){
        var num,name:String
        var type,ability:[String]
        var BS:[Int]
        var weight:Double
        let array = loadCSV(filename: "pokedata")
        for i in 0..<array.count-1{
            var split = array[i].components(separatedBy: ",")
            if pkname == split[1]{
                num = split[0]
                name = split[1]
                type = [split[2],split[3]]
                ability = [split[4],split[5],split[6]]
                BS = [Int(split[7])!,Int(split[8])!,Int(split[9])!,Int(split[10])!,Int(split[11])!,Int(split[12])!]
                weight = Double(split[13])!
                return (num,name,type,ability,BS,weight)
            }
        }
        return ("","",[],[],[],0.0)
    }
    
    
    //全ポケモン名を配列で返す
    class func allPKname() -> [String]{
        let array = loadCSV(filename: "pokedata")
        var allName = [String]()
        for i in 0 ... array.count-2{
            //print(i)
            let split = array[i].components(separatedBy: ",")
            allName.append(split[1])
        }
        return allName
    }
    
    //入力途中のポケモン名に近いものを探して返す
    //とりあえず前方一致するものを
    class func suggestPKname(hiraganaName: String) -> [String]{
        let katakana = hiraganaName.toKatakana()//カタカナに変換
        let allName = allPKname()
        var retArray = [String]()
        for i in 0 ... allName.count-1{
            if allName[i].hasPrefix(katakana){
                retArray.append(allName[i])
            }
        }
        return retArray
    }
    
    
}
