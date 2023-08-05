//
//  LandingView.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//

import SwiftUI
import weathercore

@available(iOS 13.0, *)
struct WeatherView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    //Weather API service
    @Environment(\.weatherService) var apiService: IWeatherWorker
    //
    @ObservedObject var viewModel: WeatherViewModel
    
    var loadErrorActionSheet: ActionSheet{
        
        ActionSheet(title: Text("Error").font(.title), message: Text("\(viewModel.errorMessage)"), buttons: [
            .default(Text("Try Again"), action: {
                //
                viewModel.updateForecast(withLocation: viewModel.location)
            }),.cancel(Text("Dismiss"),action: {
                //
                viewModel.loadCachedWeather()
            })])
    }
    
    var allowLocationPermissionActionSheet: ActionSheet{
        
        ActionSheet(title: Text("Location Permission Required").font(.system(size: 22)), message: Text("This app requires your permission to work properly, please allow in settings.."), buttons: [
            .default(Text("Allow Access .."), action: {
                //
                if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }else{
                    //Failed
                }
            }),.cancel(Text("Use Dafault Location"),action: {
                //
                viewModel.location = viewModel.defaultLocation
            })])
    }
    
    //Will be shown when Locations service are disabled or missiong
    var locationServiceNotAvailableActionSheet: ActionSheet{
        
        ActionSheet(title: Text("Location Services Missing").font(.system(size: 22)), message: Text("It appears your device does not have location services or they have been disable.\n\nThis app requires your location to work properly"), buttons: [
            .default(Text("Use Dafault Location"), action: {
                //
                viewModel.location = viewModel.defaultLocation
            }),.cancel(Text("Close"),action: {
                //
            })])
    }
    //
    init(){
        //
        viewModel = WeatherViewModel()
        //
        // iOS 13 : To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
    }
    
    
    var body: some View {
        
        GeometryReader { parentGeometry in
            
            //
            LoadingView(title: nil, isShowing: $viewModel.isLoading) {
                
                //
                VStack{
                    
                    GeometryReader { geometry in
                    
                        ZStack{
                            //Weather Image
                            Image(viewModel.currentImage)
                                .resizable().scaledToFill()
                                .frame(width: parentGeometry.size.width, height: parentGeometry.size.height * 0.45, alignment: .center)
                                .edgesIgnoringSafeArea(.all)
                            //
                            VStack{
                                //Current Temp
                                Text(viewModel.currentTemp)
                                    .font(.system(size: 72))
                                    .foregroundColor(Color.white)
                                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                //Weather Name
                                Text(viewModel.currentWeather)
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 48))
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                                    .minimumScaleFactor(0.01)
                                    .lineLimit(1)
                                //Padded Bottom Spacer
                                    Spacer()
                                    .frame(minHeight: 0, idealHeight: geometry.size.height * 0.2, maxHeight: 200)
                                    .fixedSize()
                            }
                        }
                    }
                    
                    //
                    HStack(spacing: 10){
                        
                        //
                        VStack{
                            
                            Text(viewModel.currentMinTemp)
                                .foregroundColor(Color.white)
                                .font(.system(size: 28))
                            
                            Text("min")
                                .foregroundColor(Color.white)
                                .font(.system(size: 22))
                        }
                        //
                        Spacer()
                        //
                        VStack{
                            
                            Text(viewModel.currentTemp)
                                .foregroundColor(Color.white)
                                .font(.system(size: 28))
                            
                            Text("Current")
                                .foregroundColor(Color.white)
                                .font(.system(size: 22))
                        }
                        
                        Spacer()
                        //
                        VStack{
                            
                            Text(viewModel.currentMaxTemp)
                                .foregroundColor(Color.white)
                                .font(.system(size: 28))
                            
                            Text("max")
                                .foregroundColor(Color.white)
                                .font(.system(size: 22))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    //Line
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: parentGeometry.size.width, height: 1)
                    
                    //Forecast Items ...
                    List {
                        //
                        if viewModel.forecastEntries.isEmpty && !viewModel.isLoading {
                            //Place holder for empty list
                            if viewModel.errorMessage.lengthOfBytes(using: .utf8) > 0 {
                                
                                Text("Loaded Forecast Failed..")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .listRowBackground(Color.clear)
                            }else{
                                
                                Text("No Forecast Weather Loaded ...")
                                    .frame(maxWidth: .infinity)
                                    .background(Color.clear)
                                    .foregroundColor(.white)
                                    .listRowBackground(Color.clear)
                            }
                        }else{
                            //Show the items
                            ForEach(viewModel.forecastEntries) {item in
                                //
                                if #available(iOS 15.0, *) {
                                    ForecastRowView.init(weather:item)
                                        .onAppear {
                                            //
                                        }
                                        .animation(.easeIn)
                                        .listRowSeparator(.hidden)
                                } else {
                                    //
                                    ForecastRowView.init(weather:item)
                                        .onAppear {
                                            //
                                        }
                                        .animation(.easeIn)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .listRowBackground(Color.red)
                    .background(Color.clear)
                    .environment(\.horizontalSizeClass, .regular)
                    //.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
            }
           
        }
        .background(Color(uiColor:viewModel.currentBackgroundColor))
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            //
            viewModel.requestLocationAccessAuthorisation()
        }
        .actionSheet(isPresented: $viewModel.showErrorAlert) {
            loadErrorActionSheet
        }
        .actionSheet(isPresented: $viewModel.showPermissionsAlert) {
            allowLocationPermissionActionSheet
        }
        .actionSheet(isPresented: $viewModel.showLocationServicesAlert) {
            locationServiceNotAvailableActionSheet
        }
    }

}


#if DEBUG
@available(iOS 13.0, *)
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ "iPhone 11 Pro Max", "iPhone SE (2nd generation)"], id: \.self) { deviceName in
            WeatherView()
        }
    }
}
#endif
