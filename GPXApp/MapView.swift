//
//  MapView.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/30/24.
//
import MapKit
import SwiftUI



func search(for query: String) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.resultTypes = .pointOfInterest
    request.region = MKCoordinateRegion(
        center: (CLLocationCoordinate2D(latitude: 40.7127, longitude: -73.9654)),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
}
