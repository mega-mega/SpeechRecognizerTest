//
//  ViewController.swift
//  SpeechRecognizerTest
//
//  Created by T Shibuya on 2018/02/20.
//  Copyright © 2018年 T S. All rights reserved.
//

import UIKit
import Speech
import RealmSwift
class ViewController: UIViewController,SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    private var names:[String] = [String]()
    private var text:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        button.isEnabled = false
        //makeDB()
        let frgn:furigana = furigana()
        //frgn.test()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func makeDB(){
        print("realm test start")
        let realm = try! Realm()
        let fileManager = FileManager()
        let pokemonRealmPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/pokemon.realm"
        // 初期データを作成するため、前回作成したデータがあったら削除する
        if fileManager.fileExists(atPath: pokemonRealmPath) { try! fileManager.removeItem(atPath: pokemonRealmPath) }
        try! realm.write { realm.deleteAll() }
        let allpokename = CSVpokedata.allPKname()
        for i in 0 ... allpokename.count-1{
            let data = CSVpokedata.loadPKdata(pkname: allpokename[i])
            let pokemon = Pokemon()
            pokemon.id = i
            pokemon.indexnum = data.num
            pokemon.name = data.name
            pokemon.type1 = data.type[0]
            pokemon.type2 = data.type[1] == "x" ? nil : data.type[1]
            pokemon.ability1 = data.ability[0]
            pokemon.ability2 = data.ability[1] == "x" ? nil : data.ability[1]
            pokemon.ability3 = data.ability[2] == "x" ? nil : data.ability[2]
            pokemon.bsHP = data.BS[0]
            pokemon.bsA = data.BS[1]
            pokemon.bsB = data.BS[2]
            pokemon.bsC = data.BS[3]
            pokemon.bsD = data.BS[4]
            pokemon.bsS = data.BS[5]
            pokemon.weight = data.weight
            try! realm.write {
                realm.add(pokemon)
            }
        }
        try! Realm().writeCopy(toFile: URL(string: pokemonRealmPath)!, encryptionKey: Data(base64Encoded: "pokemon"))
        print("end make db")
        // Realmのインスタンスを取得
        let realmtest = try! Realm()
        // Realmに保存されてるDog型のオブジェクトを全て取得
        let pk = realmtest.objects(Pokemon.self)
        // ためしに名前を表示
        var names = ""
        for poke in pk {
            print("name: \(poke.name)")
            names += poke.name
        }
        textView.text = names
        print(pokemonRealmPath)
        //end of realmTest
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.button.isEnabled = true
                    
                case .denied:
                    self.button.isEnabled = false
                    self.button.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.button.isEnabled = false
                    self.button.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.button.isEnabled = false
                    self.button.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode:AVAudioInputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                //self.textView.text = result.bestTranscription.formattedString
                var apptext:String = result.bestTranscription.formattedString
                print(apptext + "\(apptext.count)")
                apptext = String(apptext.suffix(apptext.count - self.text.count))
                print(apptext + "\(apptext.count)  \(self.text.count)")
                self.names.append(apptext)
                self.text += apptext
                
                var setText = ""
                for item in self.names{
                    setText += item + "\n"
                }
                self.textView.text = setText
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.button.isEnabled = true
                self.button.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        textView.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            button.isEnabled = true
            button.setTitle("Start Recording", for: [])
        } else {
            button.isEnabled = false
            button.setTitle("Recognition not available", for: .disabled)
        }
    }
    @IBAction func buttonTapped(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            button.isEnabled = false
            button.setTitle("Stopping", for: .disabled)
        } else {
            try! startRecording()
            button.setTitle("Stop recording", for: [])
        }
    }
}

