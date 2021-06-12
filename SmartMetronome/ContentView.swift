//
//  ContentView.swift
//  SmartMetronome
//
//  Created by Thomas Ring on 6/12/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var appState = AppState()
    
    var body: some View {
        VStack {
            Text("Time signature is \(appState.beatsPerBar)/\(appState.subdivision)")
                .font(.title)
            
            Spacer()
            
            Text("Current beat is")
            Text("\(appState.currentBeat)")
                .font(.largeTitle)
            
            Spacer()
            
            HStack {
                Spacer()
                if !self.appState.metronomeRunning {
                    Button("Start") { self.appState.start() }
                } else {
                    Button("Stop") { self.appState.stop() }
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
        .onAppear { self.appState.restartDetection() }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
