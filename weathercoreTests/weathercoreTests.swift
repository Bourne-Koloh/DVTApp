//
//  weathercoreTests.swift
//  weathercoreTests
//
//  Created by Bourne Koloh on 06/08/2023.
//  Email : bournekolo@icloud.com
//

import XCTest
import Combine
@testable import weathercore

@available(iOS 13.0, *)//Because of combine
final class weathercoreTests: XCTestCase {
    
    private var apiService:IWeatherWorker!
    private var dataStore:IDataStore!
    private var cancellables: Set<AnyCancellable>!
    
    //Test Location
    let location = (-1.2822074, 36.819080)
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        apiService = WeatherWorkerImpl.getImpl()
        dataStore = DataStoreImpl.Shared
        cancellables = []
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        apiService = nil
        dataStore = nil
        cancellables = nil
    }
    
    /**
     * MARK: This function is test for reuest to fetch current weather
     */
    func testFetchCurrentWeather() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        
        var weather:WeatherItem? = nil
        var error: Error?
        let expectation = self.expectation(description: "TestForecastData")
        
        //
        apiService.loadCurrentWeather(withLocation: location) { result, state in
            
            if let result = result{
                weather = result
            }else{
                error = state
                //Failed
            }
            // Fullfilling our expectation to unblock
            // our test execution:
            expectation.fulfill()
        }
        
        
        // Awaiting fulfilment of our expecation before
        // performing our asserts:
        waitForExpectations(timeout: 10)
        
        
        // Asserting that our execution yielded the
        // correct output:
        XCTAssertNil(error)
        XCTAssertGreaterThan(weather?.weather.count ?? 0, 1)
    }
    
    /**
     * MARK: This function is test for reuest to fetch weather forecast and store it in Data Cache(Core Data)
     */
    @available(iOS 13.0, *)
    func testFetchForecast() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        
        var forecast:ForecastItem? = nil
        var error: Error?
        let expectation = self.expectation(description: "TestForecastData")
        
        //
        apiService.loadForecastWeather(forLocation: location)
            .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let encounteredError):
                error = encounteredError
            }

            // Fullfilling our expectation to unblock
            // our test execution:
            expectation.fulfill()
        }, receiveValue: { result in
            forecast = result
        })
        .store(in: &cancellables)
        
        
        // Awaiting fulfilment of our expecation before
        // performing our asserts:
        waitForExpectations(timeout: 10)
        
        // Asserting that our execution yielded the
        // correct output:
        XCTAssertNil(error)
        XCTAssertEqual(forecast?.entries.count, 5)
    }
    /**
     * MARK: This function tests performance, for reuest to fetch weather forecast and store it in Data Cache(Core Data), the clear the data
     */
    func testIntegrationsPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
            var forecast:WeatherItem? = nil
            var error: Error?
            let expectation = self.expectation(description: "TestForecastData")
            
            
            //
            apiService.loadCurrentWeather(withLocation: location) { result, state in
                
                if let result = result{
                    forecast = result
                    expectation.fulfill()
                }else{
                    error = state
                    //Failed
                }
            }
            
            
            // Awaiting fulfilment of our expecation before
            // performing our asserts:
            waitForExpectations(timeout: 10)
            
            // Asserting that our execution yielded the
            // correct output:
            XCTAssertNil(error)
            XCTAssertGreaterThan(forecast?.weather.count ?? 0, 1)
            
            //Clear cached items
            for item in dataStore.loadForecastItems(){
                _ = dataStore.dropForecastRecord(with: item)
            }
        }
    }

}

