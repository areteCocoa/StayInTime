//
//  ContentView.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/12/21.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    // Time signature
    var beatsPerBar: Int { 4 }
    var subdivision: Int { 4 }
    
    var tickEffect: AVAudioPlayer? = {
        return try! AVAudioPlayer(contentsOf: url)
    }()
    private static var path: String { Bundle.main.path(forResource: "tick", ofType: "wav")! }
    private static var url: URL { URL(fileURLWithPath: path) }
    
    @State var currentBeat: Int = 1
    @State var beatsPerMinute: Double = 60
    @State private var timer: Timer?

    private var isRunning: Bool { timer != nil }
    private var beatsPerSecond: Double { beatsPerMinute / 60 }
    
    var body: some View {
        VStack {
            Text("Time signature is \(beatsPerBar)/\(subdivision)")
                .font(.title)
            
            Spacer()
            
            Text("Current beat is")
            Text("\(currentBeat)")
                .font(.largeTitle)
            
            Spacer()
            
            HStack {
                Spacer()
                if !isRunning {
                    Button("Start") { self.start() }
                } else {
                    Button("Stop") { self.stop() }
                }
                Spacer()
            }
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(Color.green)
            .cornerRadius(16)
            .padding()
            
        }
    }
    
    func start() {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
