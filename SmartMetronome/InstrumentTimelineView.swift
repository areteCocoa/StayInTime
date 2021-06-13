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
                    Text("\(formatted(playTime))")
                        .font(.title)
                    Text("Play time")
                    
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("\(formatted(idleTime))")
                        .font(.title)
                    Text("Idle time")
                    
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("\(formatted(totalTime))")
                        .font(.title)
                    Text("Total time")
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.pink)
            List {
                ForEach(0..<playChunks.count) { index in
                    HStack(spacing: 0) {
                        Text(" \(formatted(abs(playChunks[index].stop.timeIntervalSince(playChunks[index].start))))")
                            .font(.headline)
                        Text(" of playtime")
                        Spacer()
                        Text("\(formatted(start: playChunks[index].start, end: playChunks[index].stop))")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Play time")
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
    static var timeline: InstrumentTimeline {
        let interval: TimeInterval = 10
        let count = 10
        let timeline = InstrumentTimeline()
        (0..<count).forEach { offset in
            let start = Date().addingTimeInterval(-interval*Double(offset))
            let end =
            Date().addingTimeInterval(-interval*Double((offset-1)))
            timeline.playHistory.append(.init(start: start, stop: end, instrument: timeline.currentInstrument))
        }
        return timeline
    }
    
    static var previews: some View {
        NavigationView {
            InstrumentTimelineView(instrumentTimeline: timeline)
        }
    }
}
