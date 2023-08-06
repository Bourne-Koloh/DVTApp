//
//  ForecasrRowView.swift
//  weatherapp
//
//  Created by Bourne Koloh on 05/08/2023.
//  Email : bournekolo@icloud.com
//

import SwiftUI
import weathercore

@available(iOS 13.0, *)
struct ForecastRowView: View {
    
    private let weather: WeatherItem
    //
    let dateFormatter = DateFormatter()
    init(weather: WeatherItem) {
        self.weather = weather
        //
        dateFormatter.dateFormat = "EEEE"
    }
    
    var body: some View {
        
            
        GeometryReader { geometry in
            HStack{
                
                Text(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt))))
                    .foregroundColor(Color.white)
                    .font(.system(size: 22))
                    .frame(minWidth: 0, maxWidth: geometry.size.width * 0.4, alignment: .leading)
                
                Spacer()
                
                Image(weather.weather.first?.main == "Clouds" ? "partlysunny" : weather.weather.first?.main == "Rain" ? "rain" : "clear")
                    .resizable().scaledToFit()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(minWidth: 0, maxWidth: geometry.size.width * 0.2, alignment: .center)
                
                Spacer()
                
                Text("\(Int(weather.main?.temp ?? 0))°")
                    .foregroundColor(Color.white)
                    .font(.system(size: 22))
                    .frame(minWidth: 0, maxWidth: geometry.size.width * 0.4, alignment: .trailing)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
        .listRowBackground(Color.clear)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
@available(iOS 13.0, *)
struct ForecastRowView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ "iPhone 11 Pro Max", "iPhone SE (2nd generation)"], id: \.self) { deviceName in
            ForecastRowView(weather: WeatherItem()).background(Color(uiColor: UIUtils.colorWeatherSeaRain))
        }
    }
}
#endif
