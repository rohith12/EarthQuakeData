//
//  EarthQuakeDetailsTests.swift
//  EarthQuakeDetailsTests
//
//  Created by Rohith Raju on 4/1/21.
//  Copyright © 2021 Rohith Raju. All rights reserved.
//

import XCTest
@testable import EarthQuakeDetails

class EarthQuakeDetailsTests: XCTestCase {
    var sut: EarthQuakeViewModel!
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


}


class MockAPIService: ServiceProtocol {
    
    func requestForEarthQuakeData(handler: @escaping (Result<EarthQuakeResponse, Error>) -> Void) {
        var stub = StubGenerator()
        stub.stubPhotos()
    }
}

class StubGenerator {
    func stubPhotos() -> EarthQuakeResponse? {
        if let path = Bundle.main.path(forResource: "content", ofType: "json") {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let earthQuakeResponse = try? decoder.decode(EarthQuakeResponse.self, from: data)
            return earthQuakeResponse
        } else {
            return nil
        }
    }
}
