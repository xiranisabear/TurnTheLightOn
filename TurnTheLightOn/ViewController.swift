//
//  ViewController.swift
//  TurnTheLightOn
//
//  Created by Xiran Yang on 4/10/19.
//  Copyright © 2019 Xiran Yang. All rights reserved.
//

import UIKit

import AVFoundation



class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    let circleArray = ["1.jpg","2.jpg"]
    var index = 0
    
    @IBOutlet weak var lightoff: UIImageView!

    var timer: Timer?
    var recorder: AVAudioRecorder!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestAuthorization()
        
        if self.recorder != nil {
            return
        }
        
        
        let url: NSURL = NSURL(fileURLWithPath: "/dev/null")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.recorder = try AVAudioRecorder(url: url as URL, settings: settings )
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = true
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.record)))
            
            self.recorder.record()
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshAudioView(_:)), userInfo: nil, repeats: true)
        } catch {
            print("Fail to record.")
        }
    
    
        
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(tapGestureRecognizer:)))
        
        lightoff.isUserInteractionEnabled = true
        lightoff.addGestureRecognizer(tapGestureRecognizer)
    
    }

@objc internal func refreshAudioView(_: Timer) {
    recorder.updateMeters()
    
    let level = recorder.averagePower(forChannel: 0)
    print("Level Number: ", level)
    
    if(level > -5){
        toggleTorch(on: true)
        self.index = (self.index >= self.circleArray.count-1) ? 0 : self.index+1
        self.lightoff.image = UIImage(named:circleArray[index])
        
    }else{
        toggleTorch(on: false)
    }
    
 
}

    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
       print("is tapped")
        self.index = (self.index >= self.circleArray.count-1) ? 0 : self.index+1
        self.lightoff.image = UIImage(named:circleArray[index])
        
        print(self.index)
        if(self.index == 1){
            toggleTorch(on: true)
        }else{
            toggleTorch(on: false)
        }
        
    }

    
    func requestAuthorization(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            print("Permission granted")
        case AVAudioSessionRecordPermission.denied:
            print("Pemission denied")
        case AVAudioSessionRecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
                print("The sound level:")
            })
        @unknown default:
            return
        }
    }



func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video)
        else {return}
    
    if device.hasTorch {
        do {
            try device.lockForConfiguration()
            
            if on == true {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}
}

fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
