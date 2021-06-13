//
//  InstrumentTimelineView.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/13/21.
//

import SwiftUI

struct InstrumentTimelineView: View {
    var instrumentTimeline: InstrumentTimeline
    
    var body: some View {
        PlaytimeView(
            playTime: instrumentTimeline.playTime,
            idleTime: instrumentTimeline.idleTime,
            playChunks: instrumentTimeline.playHistory
        )
    }
}

struct PlaytimeView: View {
    var playTime: TimeInterval
    var idleTime: TimeInterval
    var totalTime: TimeInterval { playTime + idleTime }
    var playChunks: [InstrumentTimeline.PlayDuration]
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Play time")
                    Text("\(formatted(playTime))")
                }
                VStack {
                    Text("Idle time")
                    Text("\(formatted(idleTime))")
                }
                VStack {
                    Text("Total time")
                    Text("\(formatted(totalTime))")
                }
            }
            List {
                ForEach(0..<playChunks.count) { index in
                    Text("(\(formatted(start: playChunks[index].start, end: playChunks[index].stop))) Played for \(formatted(abs(playChunks[index].stop.timeIntervalSince(playChunks[index].start))))")
                }
            }
        }
    }
    
    func formatted(start: Date, end: Date) -> String {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: start, to: end)
    }
    
    func formatted(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: timeInterval)!
    }
}

struct InstrumentTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentTimelineView(instrumentTimeline: .init())
    }
}
