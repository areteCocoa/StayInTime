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
    
    static var instrumentIdentifiers: [String] {
        [
            "plucked_string_instrument",
            "synthesizer",
            "piano",
            "bowed_string_instrument",
            "electric_piano",
            "violin_fiddle"
        ]
    }
    
    // The threshold for someone "playing" and instrument
    private let playingThreshold: Double = 0.5
    
    // The identifier found above, nil if it is not playing, non-nil
    // if it is currently playing and the date is when it started
    private var instrumentPlayStart: [String: Date?] = [:]
    
    private var playHistory: [PlayDuration] = []
    
    func update(_ instruments: [(String, Double)]) {
        instruments.forEach { identifier, confidence in
            let now = Date()
            let playStartDate = instrumentPlayStart[identifier]
            let isCurrentlyPlaying = confidence >= playingThreshold
            
            if !isCurrentlyPlaying, let maybeDate = playStartDate, let date = maybeDate {
                let duration = PlayDuration(start: date, stop: now, instrument: identifier)
                playHistory.append(duration)
                instrumentPlayStart[identifier] = nil
                print("Stopped playing \(identifier)")
            } else if isCurrentlyPlaying, playStartDate == nil {
                instrumentPlayStart[identifier] = now
                print("Started playing \(identifier)")
            }
        }
    }
}
