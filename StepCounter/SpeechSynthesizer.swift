import UIKit
import AVFoundation

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    let languageCode = "de-DE"
    let synthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    var onComplete:()->() = {}

    
    override init() {
        super.init()
        
        synthesizer.delegate = self
    }
    
    func speak(text:String, onComplete:()->()) {
        
        let speech = AVSpeechUtterance(string: text)
        speech.rate = 0.5
        speech.voice = AVSpeechSynthesisVoice(language: self.languageCode)
        
        synthesizer.speakUtterance(speech)
        
        self.onComplete = onComplete
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        onComplete()
    }
}
