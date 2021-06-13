//
//  ContentView.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/12/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var appState = AppState()
    
    @State var showAnalytics: Bool = false
    
    var body: some View {
        NavigationView {
            MetronomeView(
                configuring: false,
                beatsPerBar: $appState.beatsPerBar,
                beatValue: $appState.beatValue,
                beatsPerMinute: $appState.beatsPerMinute,
                currentBeat: $appState.currentBeat,
                metronomeRunning: $appState.metronomeRunning,
                onStart: { self.appState.start() },
                onStop: { self.appState.stop() },
                onChangeBpm: { self.appState.beatsPerMinute = $0 },
                onChangeBeatsPerBar: { self.appState.beatsPerBar = $0 },
                onChangeBeatValue: { self.appState.beatValue = $0 },
                analyticsData: { self.appState.instrumentTimeline }
            )
                .navigationBarHidden(true)
                .onAppear { self.appState.restartDetection() }
        }
    }
}

struct MetronomeView: View {
    
    @State var configuring: Bool
    
    @Binding var beatsPerBar: Int
    @Binding var beatValue: Int
    @Binding var beatsPerMinute: Double
    
    @Binding var currentBeat: Int
    @Binding var metronomeRunning: Bool
    
    var onStart: (() -> Void)
    var onStop: (() -> Void)
    
    var onChangeBpm: ((Double) -> Void)
    var onChangeBeatsPerBar: ((Int) -> Void)
    var onChangeBeatValue: ((Int) -> Void)
    
    var analyticsData: (() -> InstrumentTimeline)
    
    struct Beat: Identifiable {
        typealias ObjectIdentifier = Int
        var id: ObjectIdentifier { number }
        var number: Int
    }
    
    var beats: [Beat] {
        (1..<(beatsPerBar + 1))
            .map { Beat(number: $0) }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        if configuring {
                            VStack {
                                Stepper {
                                    HStack(alignment: .center, spacing: 4) {
                                        Text("\(Int(beatsPerMinute))")
                                            .font(.largeTitle)
                                            .bold()
                                        Text("beats per minute")
                                    }
                                } onIncrement: {
                                    self.onChangeBpm(self.beatsPerMinute + 1)
                                } onDecrement: {
                                    self.onChangeBpm(self.beatsPerMinute - 1)
                                }
                                Stepper {
                                    HStack(alignment: .center, spacing: 4) {
                                        Text("\(Int(beatsPerBar))")
                                            .font(.largeTitle)
                                            .bold()
                                        Text("beats per bar")
                                    }
                                } onIncrement: {
                                    self.onChangeBeatsPerBar(self.beatsPerBar + 1)
                                } onDecrement: {
                                    self.onChangeBeatsPerBar(self.beatsPerBar - 1)
                                }
                                Stepper {
                                    HStack(alignment: .center, spacing: 4) {
                                        Text("\(Int(beatValue))")
                                            .font(.largeTitle)
                                            .bold()
                                        Text("note value")
                                    }
                                } onIncrement: {
                                    self.onChangeBeatValue(self.beatValue * 2)
                                } onDecrement: {
                                    self.onChangeBeatValue(self.beatValue / 2)
                                }

                                Button(action: {
                                    withAnimation {
                                        self.configuring = false
                                    }
                                }) {
                                    Text("Done")
                                        .font(.headline)
                                        .foregroundColor(.pink)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(.white)
                                        .cornerRadius(16)
                                        
                                }
                            }
                        } else {
                            VStack {
                                Text("Time signature is \(beatsPerBar)/\(beatValue)")
                                    .font(.title)
                                Text("BPM is \(Int(beatsPerMinute))")
                            }
                            .onTapGesture {
                                withAnimation {
                                    self.configuring = true
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.pink)
                
                Spacer()
                
                Text("Current beat is")
                Text("\(currentBeat)")
                    .font(.largeTitle)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 4) {
                    ForEach(self.beats) { beat in
                        if beat.number == currentBeat {
                            Text("\(beat.number)")
                                .font(.title)
                                .bold()
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .background(.pink)
                                .cornerRadius(8)
                        } else {
                            Text("\(beat.number)")
                                .font(.title)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        if !metronomeRunning {
                            self.onStart()
                        } else {
                            self.onStop()
                        }
                    }) {
                        Text(metronomeRunning ? "Stop" : "Start")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(16)
                            .padding()
                    }
                    Spacer()
                }
                
                
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink {
                        InstrumentTimelineView(instrumentTimeline: analyticsData())
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(.pink)
                            .cornerRadius(16)
                            .padding()
                    }
                }
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView(configuring: true,
                      beatsPerBar: .constant(8),
                      beatValue: .constant(4),
                      beatsPerMinute: .constant(60),
                      currentBeat: .constant(1),
                      metronomeRunning: .constant(false),
                      onStart: {},
                      onStop: {},
                      onChangeBpm: { _ in },
                      onChangeBeatsPerBar: { _ in },
                      onChangeBeatValue: { _ in },
                      analyticsData: { InstrumentTimeline() })
    }
}
