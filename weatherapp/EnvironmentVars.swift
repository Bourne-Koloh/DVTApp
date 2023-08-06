//
//  EnvironmentVars.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
import weathercore

struct ApiServiceKey: EnvironmentKey {
    static let defaultValue: IWeatherWorker = WeatherWorkerImpl.getImpl()
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var weatherService: IWeatherWorker {
        get {
            return self[ApiServiceKey.self]
        }
        set {
            self[ApiServiceKey.self] = newValue
        }
    }
}
struct DataStoreServiceKey: EnvironmentKey {
    static let defaultValue: IDataStore = DataStoreImpl.Shared
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    var dataStoreService: IDataStore {
        get {
            return self[DataStoreServiceKey.self]
        }
        set {
            self[DataStoreServiceKey.self] = newValue
        }
    }
}
