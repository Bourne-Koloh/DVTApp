//
//  LandingView.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//

import SwiftUI
import weathercore

@available(iOS 13.0, *)
struct LandingView: View {
    //
    @Environment(\.weatherService) var weatherService: IWeatherWorker
    @Environment(\.dataStoreService) var dataStoreService: IDataStore

    var body: some View {
        NavigationView {
           
            Text("Select an item")
        }
    }

}

@available(iOS 13.0, *)
struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ "iPhone 11 Pro Max", "iPhone SE (2nd generation)"], id: \.self) { deviceName in
            LandingView()
        }
    }
}
