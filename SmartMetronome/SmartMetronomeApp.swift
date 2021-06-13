//
//  SmartMetronomeApp.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/12/21.
//

import SwiftUI
import Combine
import AVFoundation
import SoundAnalysis


class AppState: ObservableObject {
    
    private var detectionCancellable: AnyCancellable? = nil
    
    private var tickEffect: AVAudioPlayer? = {
        return try! AVAudioPlayer(contentsOf: url)
    }()
    private static var path: String { Bundle.main.path(forResource: "tick", ofType: "wav")! }
    private static var url: URL { URL(fileURLWithPath: path) }
    
    private var lastActedTime: Date?
    
    private var snapTimeline: SnapTimeline = SnapTimeline()
    var instrumentTimeline: InstrumentTimeline = InstrumentTimeline()
    
    @Published var beatsPerBar: Int = 4
    @Published var beatValue: Int = 4
    
    @Published var currentBeat: Int = 1
    @Published var beatsPerMinute: Double = 60
    var beatsPerSecond: Double { 60 / beatsPerMinute }
    private var timer: Timer? {
        didSet {
            metronomeRunning = (timer != nil)
        }
    }
    
    @Published var soundDetectionRunning: Bool = false
    @Published var metronomeRunning: Bool = false
    
    init() {
        snapTimeline.didSetBpm = {
            guard let bpm = self.snapTimeline.beatsPerMinute else { return }
            self.beatsPerMinute = Double(bpm)
            self.start()
        }
    }
    
    func restartDetection() {
        AudioManager.singleton.stopSoundClassification()
        
        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()
        
        detectionCancellable =
        classificationSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in self.soundDetectionRunning = false },
                  receiveValue: { value in
                let instruments = value.classifications.filter { self.instrumentTimeline.currentInstrument == $0.identifier }
                self.instrumentTimeline.update(instruments.map { ($0.identifier, $0.confidence) })
                
                guard let snap = value.classifications.first(where: { $0.identifier == "finger_snapping" }) else { return }
                
                if !self.metronomeRunning {
                    self.snapTimeline.add(confidence: snap.confidence)
                }
                
                let threshold: Double = 2
                if let lastActedTime = self.lastActedTime {
                    let earliestTimeToAct = lastActedTime.addingTimeInterval(threshold)
                    let now = Date()
                    // If it's too early then the snap will still be detected, so we
                    // limit the time between actions.
                    if now < earliestTimeToAct {
                        return
                    }
                }
            })
        
        AudioManager.singleton.startSoundClassification(subject: classificationSubject,
                                                        inferenceWindowSize: Double(0.5),
                                                        overlapFactor: Double(0.9))
    }
    
    func start() {
        currentBeat = 0
        incrementBeat()
        
        let timer = Timer.scheduledTimer(withTimeInterval: self.beatsPerSecond, repeats: true) { _ in
            self.incrementBeat()
        }
        self.timer = timer
    }
    
    func stop() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func incrementBeat() {
        currentBeat = (currentBeat % beatsPerBar) + 1
        tick()
    }
    
    func tick() {
        self.tickEffect!.play()
    }
}

@main
struct SmartMetronomeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
