//
//  AudioManager.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/12/21.
//

import Foundation
import AVFoundation
import SoundAnalysis
import Combine


final class AudioManager {
    enum AudioClassificationError: Error {
        case audioStreamInterrupted
        case noMicrophoneAccess
    }
    
    private let analysisQueue = DispatchQueue(label: "com.smartmetronome.audio.analysis")
    
    // Records audio input
    private var audioEngine: AVAudioEngine?
    
    // Performs sound classification
    private var analyzer: SNAudioStreamAnalyzer?
    
    private var retainedObservers: [SNResultsObserving]?
    
    // A subject to deliver the results/errors to
    private var subject: PassthroughSubject<SNClassificationResult, Error>?
    
    // Singleton protection
    private init() {}
    
    static let singleton = AudioManager()
    
    private func ensureMicrophoneAccess() throws {
        var hasMicrophoneAccess = false
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            let sem = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(for: .audio) { success in
                hasMicrophoneAccess = success
                sem.signal()
            }
            _ = sem.wait(timeout: DispatchTime.distantFuture)
        case .restricted, .denied:
            break
        case .authorized:
            hasMicrophoneAccess = true
        @unknown default:
            fatalError("Unknown case for microphone access switch.")
        }
        
        if !hasMicrophoneAccess {
            throw AudioClassificationError.noMicrophoneAccess
        }
    }
    
    private func startAudioSession() throws {
        stopAudioSession()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // TODO: Does this need to be `.playAndRecord` or just `.record`?
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            stopAudioSession()
            throw error
        }
    }
    
    private func stopAudioSession() {
        autoreleasepool {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setActive(false)
        }
    }
    
    private func startListeningForAudioSessionInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterrupted),
            name: AVAudioSession.interruptionNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterrupted),
            name: AVAudioSession.mediaServicesWereLostNotification,
            object: nil)
    }
    
    private func stopListeningForAudioSessionInterruptions() {
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.mediaServicesWereLostNotification,
            object: nil)
    }
    
    @objc
    private func handleAudioSessionInterrupted(_ notification: Notification) {
        let error = AudioClassificationError.audioStreamInterrupted
        subject?.send(completion: .failure(error))
        // TODO: stopSoundClassification()
    }
    
    private func startAnalyzing(_ requestsAndObservers: [(SNRequest, SNResultsObserving)]) throws {
        stopAnalyzing()
        
        do {
            try startAudioSession()
            
            try ensureMicrophoneAccess()
            
            let newAudioEngine = AVAudioEngine()
            audioEngine = newAudioEngine
            
            let busIndex = AVAudioNodeBus(0)
            let bufferSize = AVAudioFrameCount(4096)
            let audioFormat = newAudioEngine.inputNode.outputFormat(forBus: busIndex)
            
            let newAnalyzer = SNAudioStreamAnalyzer(format: audioFormat)
            analyzer = newAnalyzer
            
            try requestsAndObservers.forEach { try newAnalyzer.add($0.0, withObserver: $0.1) }
            retainedObservers = requestsAndObservers.map { $0.1 }
            
            newAudioEngine.inputNode.installTap(
                onBus: busIndex,
                bufferSize: bufferSize,
                format: audioFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.analysisQueue.async {
                    newAnalyzer.analyze(buffer, atAudioFramePosition: when.sampleTime)
                }
            }
            
            try newAudioEngine.start()
        } catch {
            stopAnalyzing()
            throw error
        }
    }
    
    private func stopAnalyzing() {
        autoreleasepool {
            if let audioEngine = audioEngine {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }
            
            if let analyzer = analyzer {
                analyzer.removeAllRequests()
            }
            
            analyzer = nil
            retainedObservers = nil
            audioEngine = nil
        }
        stopAudioSession()
    }
    
    func startSoundClassification(subject: PassthroughSubject<SNClassificationResult, Error>,
                                  inferenceWindowSize: Double,
                                  overlapFactor: Double) {
        stopSoundClassification()
        
        do {
            let observer = ClassificationResultsSubject(subject: subject)
            
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            request.windowDuration = CMTimeMakeWithSeconds(inferenceWindowSize, preferredTimescale: 40_000)
            request.overlapFactor = overlapFactor
            
            self.subject = subject
            
            startListeningForAudioSessionInterruptions()
            try startAnalyzing([(request, observer)])
        } catch {
            subject.send(completion: .failure(error))
            self.subject = nil
            stopSoundClassification()
        }
    }
    
    func stopSoundClassification() {
        stopAnalyzing()
        stopListeningForAudioSessionInterruptions()
    }
}
