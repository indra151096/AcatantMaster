//
//  ViewController.swift
//  AcatantMaster
//
//  Created by Indra Sumawi on 19/09/19.
//  Copyright © 2019 Indra Sumawi. All rights reserved.
//

import UIKit
import CloudKit
import AVFoundation
import Speech
import NaturalLanguage
import YXWaveView

class ViewController: UIViewController, eventDelegate, SFSpeechRecognizerDelegate {
  
  var isStart = false
  @IBOutlet weak var speechLabel: UILabel!
  
  var onGoing = false
  
  //speech recognizer
  let audioEngine = AVAudioEngine()
  let speechRecognizer = SFSpeechRecognizer(locale: .init(identifier: "id-ID"))
  var request: SFSpeechAudioBufferRecognitionRequest!
  var recognitionTask: SFSpeechRecognitionTask?
  var node: AVAudioInputNode!
  var recordingFormat: AVAudioFormat!
  
  var waterView: YXWaveView!
  
  func happen(status: String) {
    if (status == "exit") {
      finishSession()
    }
  }
  
  @IBAction func doneButtonTapped(_ sender: Any) {
    finishSession()
  }
  
  func finishSession() {
    talk(message: "Terima Kasih. Sampai jumpa kembali!")
    stopRecognizer()
    dismiss(animated: true, completion: nil)
  }
  
  func asistantStart() {
    UIView.animate(withDuration: 1, animations: {
      self.waterView.alpha = 1
    })
    waterView.start()
    isStart = true
    let timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { timer in
      self.isStart = false
      //print("RESULT \(self.speechLabel.text)")
      let category = self.textProcess(text: self.speechLabel.text!)
      self.processRequest(category: category)
      self.speechLabel.text = ""
      self.stopRecognizer()
      self.waterView.stop()
      UIView.animate(withDuration: 1, animations: {
        self.waterView.alpha = 0
      })
      self.recordAndRecognizeSpeech()
      self.onGoing = false
    }
  }
  
  func processRequest(category: String) {
    performSegue(withIdentifier: "goToResult", sender: category)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as! ResultViewController
    vc.category = sender as! String
    print(vc.category)
  }
  
  func asistantStartWithout() {
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
      self.speechLabel.text = ""
      self.stopRecognizer()
      self.recordAndRecognizeSpeech()
      print("DONE")
      self.onGoing = false
    }
  }
  
  func recordAndRecognizeSpeech() {
    request = SFSpeechAudioBufferRecognitionRequest()
    
    audioEngine.prepare()
    do {
      try audioEngine.start()
    } catch {
      return print(error)
    }
    
    guard let myRecognizer = SFSpeechRecognizer() else {
      return
    }
    print(myRecognizer)
    if !myRecognizer.isAvailable {
      print("NOT AVAILABLE")
      return
    }
    
    recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
      if let result = result {
        let bestString =  result.bestTranscription.formattedString
        if (!self.onGoing) {
          self.onGoing = true
          if (bestString == "Asisten") {
            self.asistantStart()
          }
          else {
            self.asistantStartWithout()
          }
        }
        if self.isStart {
          self.speechLabel.text = bestString
        }
        
        print(bestString)
      }
      else if let error = error {
        print(error)
      }
    })
  }
  
  func stopRecognizer() {
    audioEngine.stop()
    request.endAudio()
    recognitionTask?.cancel()
  }
  
  func textProcess(text: String) -> String {
    do {
      let sentimentPredictor = try NLModel(mlModel: AcatantSentimentClassifier().model)
      let label = sentimentPredictor.predictedLabel(for: text)
      return label ?? ""
    }
    catch {
      print("something went wrong")
    }
    return ""
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let app = UIApplication.shared.delegate as! AppDelegate
    app.delegate = self
    // Do any additional setup after loading the view.
    
    talk(message: "Halo Indra, Ada yang bisa saya bantu?")
    
    node = audioEngine.inputNode
    recordingFormat = node.outputFormat(forBus: 0)
    node.installTap(onBus: 0, bufferSize: 10240, format: recordingFormat) { (buffer, _) in
      self.request.append(buffer)
    }
    
    self.recordAndRecognizeSpeech()
    setupAudioWave()
  }
  
  func requestTranscribePermissions() {
    SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
      DispatchQueue.main.async {
        if authStatus == .authorized {
          print("Good to go!")
        } else {
          print("Transcription permission was declined.")
        }
      }
    }
  }
  
  func transcribeAudio(url: URL) {
    // create a new recognizer and point it at our audio
    let recognizer = SFSpeechRecognizer()
    let request = SFSpeechURLRecognitionRequest(url: url)
    
    // start recognition!
    recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
      // abort if we didn't get any transcription back
      guard let result = result else {
        print("There was an error: \(error!)")
        return
      }
      
      // if we got the final transcription back, print it
      if result.isFinal {
        // pull out the best transcription...
        print(result.bestTranscription.formattedString)
      }
    }
  }
  
  func setupAudioWave() {
    // Init
    let frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200)
    waterView = YXWaveView(frame: frame, color: UIColor.white)
    
    // wave speed (default: 0.6)
    waterView.waveSpeed = 0.5
    
    // wave height (default: 5)
    waterView.waveHeight = 20
    
    // wave curvature (default: 1.5)
    waterView.waveCurvature = 1.5
    
    // real wave color
    waterView.realWaveColor = .red
    
    // mask wave color
    waterView.maskWaveColor = .purple
    
    // Add OverView
    //waterView.addOverView(self.view)
    
    self.view.addSubview(waterView)
    // Start
    //waterView.start()
    
    // Stop
    //waterView.stop()
  }
}

