//
//  ContentView.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/29/24.
//

import SwiftUI
import MapKit
import UIKit
import Combine

struct ContentView: View {
    @State private var osmData: OSMResponse = OSMResponse(version: 0.0, generator: "", osm3s: [:], elements: [])
    @State private var position: MapCameraPosition = .automatic
    
    // Location Manager stuff
    @StateObject var deviceLocationService = DeviceLocationService.shared
    
    @State var tokens: Set<AnyCancellable> = []
    @State var coordinates: (lat: Double, lon: Double) = (0.0, 0.0)
    
    var body: some View {
        VStack {
            Text("Longitude: \(coordinates.lon)")
                .font(.headline)
            Text("Latitude: \(coordinates.lat)")
                .font(.headline)
            
            Map (position: $position){
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button(action: {
                        position = .region(
                            MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                    }) {
                        Text("Move to your location")
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
                let osmData = try await getAsyncOSMData(lon: coordinates.lon, lat: coordinates.lat, radius: 100000)
                print(osmData)
            } catch {
                print("OSM Shit failed", error)
            }
        }
        .onAppear() {
            observeCoordinateUpdates()
            observeDeviceLocationDenied()
            deviceLocationService.requestLocationUpdates()
        }
    }
    
    
    func observeCoordinateUpdates() {
        deviceLocationService.coordinatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Handle \(completion) for error and finished subscription.")
            } receiveValue: { coordinates in
                self.coordinates = (coordinates.latitude, coordinates.longitude)
            }
            .store(in: &tokens)
    }
    
    func observeDeviceLocationDenied() {
        deviceLocationService.deniedLocationAccess
            .receive(on: DispatchQueue.main)
            .sink {
                print("Error on getting location")
            }
            .store(in: &tokens)
    }
}

#Preview {
    ContentView()
}
