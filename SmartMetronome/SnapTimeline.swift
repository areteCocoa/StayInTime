//
//  SnapTimeline.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/12/21.
//

import Foundation

class SnapTimeline {
    let maxSeconds: Double = 10.0
    
    // time, confidence
    var timeline: [(Date, Double)] = []
    
    // The last beats per minute snapped by the user
    var beatsPerMinute: Int? {
        didSet {
            didSetBpm?()
        }
    }
    
    var didSetBpm: (() -> Void)?
    
    var beatsPerBar: Int = 4
    
    func add(confidence: Double) {
        timeline.append((Date(), confidence))

        processTimeline()
    }
    
    func processTimeline() {
        let threshold = 0.85
        let timelineWithThreshold = timeline.map { ($0, $1 > threshold) }
        
        var datesCrossingThreshold = [Date]()
        var wasAboveThreshold = false
        for event in timelineWithThreshold {
            let date = event.0
            let crossedThreshold = event.1
            if crossedThreshold, !wasAboveThreshold {
                datesCrossingThreshold.append(date)
                wasAboveThreshold = true
            } else if !crossedThreshold {
                wasAboveThreshold = false
            }
        }
        
        // Checks if there's enough snaps to make a bar, if so then
        // calculate the BPM
        guard datesCrossingThreshold.count >= beatsPerBar else { return }
        
        // Calculate seconds between each date
        var differences: [Double] = []
        for index in (0..<(datesCrossingThreshold.count - 1)) {
            let current = datesCrossingThreshold[index]
            let next = datesCrossingThreshold[index + 1]
            let diff = next.timeIntervalSince1970 - current.timeIntervalSince1970
            differences.append(diff)
        }
        
        let average = differences.reduce(0.0, { $0 + $1 }) / Double(differences.count)
        
        // Differences must be within a certain percentage of each other, otherwise
        // it's likely old snaps still in the timeline
        let averageThreshold = 0.10
        let lowThreshold = average * (1 - averageThreshold)
        let highThreshold = average * (1 + averageThreshold)
        var isValid = true
        for difference in differences {
            guard lowThreshold <= difference && difference <= highThreshold else {
                isValid = false
                continue
            }
        }
        
        guard isValid else {
            print("Is not valid, throwing out the whole thing")
            timeline = []
            return
        }
        
        let bpm = Int(floor(60 / average))
        
        self.beatsPerMinute = bpm
        self.timeline = []
    }
}
