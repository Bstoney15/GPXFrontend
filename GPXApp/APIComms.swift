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


func getAsyncOSMData(lon: Double, lat: Double, radius: Double) async throws -> OSMResponse {
    // Calls the overpass api with the long ass http
    
    guard let url = URL(string: "https://overpass-api.de/api/interpreter") else {
        print("Invalid URL")
        let nothing = OSMResponse(version: 0.0, generator: "", osm3s: [:], elements: [])
        return nothing
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    
    // Trying out the around feature in the call. Should be useful for when user selects a distance they want i think
    let httpBody = """
    [out:json][timeout:25];
    // Define the bounding box for Overland Park, Kansas
    (
      way["footway"="sidewalk"](around:\(radius),\(lat),\(lon));
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

