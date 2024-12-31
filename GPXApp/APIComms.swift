//
//  APIComms.swift
//  GPXApp
//
//  Created by Will Lawrence on 12/29/24.
//

// OSM Async Functions

import Foundation
import MapKit


struct OSMResponse : Codable {
    var version: Float?
    var generator: String?
    var osm3s: [String:String]?
    var elements: [OSMElements]?
}

struct OSMElements : Codable {
    var type: String
    var id: Int64?
    var lat: Double?
    var lon: Double?
    var nodes: [Int64]?
    var tags: [String: String]?
}


func getAsyncOSMData() async throws -> OSMResponse {
    guard let url = URL(string: "https://overpass-api.de/api/interpreter") else {
        print("Invalid URL")
        let nothing = OSMResponse(version: 0.0, generator: "", osm3s: [:], elements: [])
        return nothing
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let httpBody = """
    [out:json][timeout:25];
    // Define the bounding box for Overland Park, Kansas
    (
      way["footway"="sidewalk"](38.8500,-94.7500,38.9900,-94.6400);
    );
    out body;
    >;
    out skel qt;
    """
    
    request.httpBody = httpBody.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    //request.setValue(NSLocalizedString("lang", comment: ""), forHTTPHeaderField:"Accept-Language");
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // 5. Validate the Response
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    // 6. Decode the JSON Response
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let osmResponse = try decoder.decode(OSMResponse.self, from: data)
    
    return osmResponse
}

