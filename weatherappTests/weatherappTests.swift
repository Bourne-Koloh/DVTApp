//
//  weatherappTests.swift
//  weatherappTests
//
//  Created by Bourne Koloh on 06/08/2023.
//  Email : bournekolo@icloud.com
//

import XCTest
@testable import weatherapp
@testable import weathercore

final class weatherappTests: XCTestCase {
    
    
    private var dataStore:IDataStore!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataStore = DataStoreImpl.Shared
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dataStore = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testDataCachePerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
            //Load all items
            let cache = dataStore.loadForecastItems()
            
            //Clear cached items
            for item in cache{
                _ = dataStore.dropForecastRecord(with: item)
            }
        }
    }

}
