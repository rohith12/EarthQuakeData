//
//  EarthQuakeResponse.swift
//  EarthQuakeDetails
//
//  Created by Rohith Raju on 4/2/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import Foundation

struct EarthQuakeResponse: Codable {
    let type: String
    let metadata: Metadata
    let features: [Feature]?
    let bbox: [Double]
}

// MARK: - Feature
struct Feature: Codable {
    let type: FeatureType
    let properties: Properties?
    let geometry: Geometry
    let id: String
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: GeometryType
    let coordinates: [Double]
}

enum GeometryType: String, Codable {
    case point = "Point"
}

// MARK: - Properties
struct Properties: Codable {
    let mag: Double?
    let place: String?
    let time, updated: Int
    let tz: Int?
    let url, detail: String?
    let felt: Int?
    let cdi, mmi: Double?
    let alert: String?
    let status: Status
    let tsunami, sig: Double?
    let code, ids, sources, types: String
    let nst: Int?
    let dmin: Double?
    let rms: Double?
    let gap: Double?
    let title: String?
}

enum Net: String, Codable {
    case ak = "ak"
    case ci = "ci"
    case hv = "hv"
    case ld = "ld"
    case mb = "mb"
    case nc = "nc"
    case nm = "nm"
    case nn = "nn"
    case pr = "pr"
    case us = "us"
    case uu = "uu"
    case uw = "uw"
}

enum Status: String, Codable {
    case automatic = "automatic"
    case reviewed = "reviewed"
    case statusAUTOMATIC = "AUTOMATIC"
    case statusREVIEWED = "REVIEWED"
}

enum FeatureType: String, Codable {
    case feature = "Feature"
}

// MARK: - Metadata
struct Metadata: Codable {
    let generated: Int
    let url: String
    let title: String
    let status: Int
    let api: String
    let count: Int
}
