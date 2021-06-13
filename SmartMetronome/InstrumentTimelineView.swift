//
//  InstrumentTimelineView.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/13/21.
//

import SwiftUI
import SwiftUICharts

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
    
    var graphData: [Double] {
        var graphData: [Double] = []
        var lastEnd: Date?
        playChunks.forEach { chunk in
            if let lastEnd = lastEnd {
                let secondsIdle = Int(abs(chunk.start.timeIntervalSince(lastEnd)))
                let playData: [Double] = (0..<secondsIdle).map { _ in 0.0 }
                graphData += playData
            }
            
            let seconds = Int(abs(chunk.start.timeIntervalSince(chunk.stop)))
            let playData: [Double] = (0..<seconds).map { _ in 1.0 }
            graphData += playData
            
            lastEnd = chunk.stop
        }
        return graphData
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
//                LineView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Full screen") // legend is optional, use optional .padding()
                MultiLineChartView(data: [(graphData, GradientColors.green)], title: "", rateValue: nil)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                
                
                Section("Detailed play time") {
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
            guard offset % 2 == 0 else { return }
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
