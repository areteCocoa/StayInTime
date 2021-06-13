//
//  InstrumentTimeline.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/13/21.
//

import Foundation

class InstrumentTimeline {
    struct PlayDuration {
        let start: Date
        let stop: Date
        let instrument: String
    }
    
    private static var instrumentIdentifiers: [String] {
        [
            "piano",
            "bowed_string_instrument"
        ]
    }
    
    var currentInstrument: String = "bowed_string_instrument"
    
    private let playStopThreshold: Double = 5.0
    
    // The threshold for someone "playing" and instrument
    private let playingThreshold: Double = 0.5
    
    // The identifier found above, nil if it is not playing, non-nil
    // if it is currently playing and the date is when it started
    private var instrumentPlayStart: [String: Date?] = [:]
    private var instrumentPlayStop: [String: Date?] = [:]
    
    private var playHistory: [PlayDuration] = []
    
    func update(_ instruments: [(String, Double)]) {
        instruments.forEach { identifier, confidence in
            let now = Date()
            let playStartDate = instrumentPlayStart[identifier]
            let playStopDate = instrumentPlayStop[identifier]
            let isCurrentlyPlaying = confidence >= playingThreshold
            
            if !isCurrentlyPlaying, let startDate = playStartDate, let startDate = startDate {
                // Stopped playing
                if let stopDate = playStopDate,
                    let stopDate = stopDate,
                    abs(stopDate.timeIntervalSince(now)) > self.playStopThreshold  {
                    let duration = PlayDuration(start: startDate, stop: now, instrument: identifier)
                    playHistory.append(duration)
                    instrumentPlayStart[identifier] = nil
                    instrumentPlayStop[identifier] = nil
                    print("(\(abs(stopDate.timeIntervalSince(now))) seconds) Stopped playing \(identifier)")
                } else if playStopDate == nil {
                    instrumentPlayStop[identifier] = now
                }
            } else if isCurrentlyPlaying, playStartDate == nil {
                instrumentPlayStart[identifier] = now
                print("Started playing \(identifier)")
            } else if isCurrentlyPlaying, playStopDate != nil {
                instrumentPlayStop[identifier] = nil
                print("(\(identifier)) Thought they were done, they were not!")
            }
        }
    }
}
