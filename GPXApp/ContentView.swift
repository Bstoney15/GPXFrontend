//
//  ContentView.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/29/24.
//

import SwiftUI
import MapKit
import UIKit

struct ContentView: View {
    @State private var osmData: OSMResponse = OSMResponse(version: 0.0, generator: "", osm3s: [:], elements: [])
    var body: some View {
        VStack {
            Map {

            }
            .mapStyle(.hybrid(elevation: .realistic))
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button(action: {
                        print("Button pressed")
                    }) {
                        Text("Tap me")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .task{
            do {
                let osmData = try await getAsyncOSMData()
            } catch {
                print("OSM Shit failed", error)
            }
        }
    }
}

#Preview {
    ContentView()
}
