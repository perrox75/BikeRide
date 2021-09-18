//
//  TestsCloudFile.swift
//  BikeRideTests
//
//  Created by perrox75 on 12/09/2021.
//

import XCTest

class TestsCloudFile: XCTestCase {

    var sutCloudFile: CloudFile!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sutCloudFile = nil

        try super.tearDownWithError()
    }
}
