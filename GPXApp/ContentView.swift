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
    @State private var selectedTab: String = "Progress"
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedTab == "Progress" {
                    ProgressPage()
                } else if selectedTab == "Explore" {
                    MapView()
                }
                
                Spacer()
                
                HStack {
                    FooterButton(iconName: "chart.bar", label: "Progress", action: {
                        selectedTab = "Progress"
                    })
                    
                    FooterButton(iconName: "figure.walk", label: "Activities", action: {
                        print("Activities button tapped")
                    })
                    
                    Spacer()
                    
                    FooterButton(iconName: "magnifyingglass", label: "Explore", action: {
                        selectedTab = "Explore"
                    })
                    
                    FooterButton(iconName: "person.crop.circle", label: "Profile", action: {
                        print("Profile button tapped")
                    })
                }
                .padding()
                .background(Color.gray)
                .shadow(radius: 5)
            }
            .overlay(
                // Only show the NavigationButton when Explore tab is selected
                selectedTab == "Explore" ? AnyView(
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            NavigationButton {
                                print("Create Route tapped")
                            }
                            .padding(.trailing, 10) // Space from right edge
                            .padding(.bottom, 85) // Move it up a little bit
                        }
                    }
                ) : AnyView(EmptyView()), alignment: .bottom
            )
        }
    }
}

struct MapView: View {
    @State private var position: MapCameraPosition = .automatic
    @StateObject var deviceLocationService = DeviceLocationService.shared
    @State var tokens: Set<AnyCancellable> = []
    
    // Coordinates for Lawrence, Kansas
    @State var coordinates: (lat: Double, lon: Double) = (38.9717, -95.2353)
    
    var body: some View {
        VStack {
            Map(position: $position) {}
                .mapStyle(.hybrid(elevation: .flat))
        }
        .task {
            do {
                let osmData = try await getAsyncOSMData(lon: coordinates.lon, lat: coordinates.lat, radius: 100000)
                print(osmData)
            } catch {
                print("OSM Data fetch failed", error)
            }
        }
        .onAppear {
            observeCoordinateUpdates()
            observeDeviceLocationDenied()
            deviceLocationService.requestLocationUpdates()
            
            // Move map to Lawrence, Kansas on appearance
            position = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
        }
    }
    
    func observeCoordinateUpdates() {
        deviceLocationService.coordinatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { coordinates in
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

struct ProgressPage: View {
    var body: some View {
        VStack {
            Text("Progress Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
    }
}

struct FooterButton: View {
    var iconName: String
    var label: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// New NavigationButton above footer with an oval shape
struct NavigationButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "location.north.fill") // Directional arrow icon
                    .font(.title2)
                    .foregroundColor(.white)
                Text("Create Route")
                    .foregroundColor(.white)
                    .font(.body)
                    .padding(.leading, 5)
            }
            .padding()
            .frame(height: 60)
            .background(Color.blue)
            .clipShape(Capsule()) // Oval shape
            .shadow(radius: 5)
        }
    }
}

#Preview {
    ContentView()
}
