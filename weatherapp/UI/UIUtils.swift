//
//  UIUtils.swift
//  weatherapp
//
//  Created by Bourne Koloh on 05/08/2023.
//

import Foundation
import UIKit

class UIUtils:NSObject{
    
    //
    static var colorPrimary = UIColor(named: "PrimaryColor") ?? UIColor(red: 0/255, green: 84/255, blue: 240/255, alpha: 1)
    //
    static var colorPrimaryDark = UIColor(named: "PrimaryDarkColor") ?? UIColor(red: 0/255, green: 111/255, blue: 255/255, alpha: 1)
    //
    static var colorAccent = UIColor(named: "AccentColor") ?? UIColor(red: 255/255, green: 125/255, blue: 0, alpha: 1)
    //
    static var colorTextAccent = UIColor(named: "TextAccentColor") ?? UIColor(red: 255/255, green: 125/255, blue: 0, alpha: 1)
    //
    static var colorTextBlack = UIColor(named: "TextBlackColor") ?? UIColor.black
    //
    static var colorTextWhite = UIColor(named: "TextWhiteColor") ?? UIColor.white
    
    //
    static var colorWeatherSeaClouds = UIColor(named: "WeatherSeaCloudsColor") ?? UIColor(red: 84/255, green: 113/255, blue: 122/255, alpha: 1)
    //
    static var colorWeatherSeaSunny = UIColor(named: "WeatherSunnyColor") ?? UIColor(red: 74/255, green: 133/255, blue: 226/255, alpha: 1)
    //
    static var colorWeatherSeaRain = UIColor(named: "WeatherRainColor") ?? UIColor(red: 87/255, green: 87/255, blue: 93/255, alpha: 1)
    
    //Contraint to help adapt UIKit Views to different device classes
    //Height with respect to stroryboard design time device (iPhone XS Max)
    static let screenHeightRatio = UIScreen.main.bounds.height / 896.0
    //Width ratio with respect to  stroryboard design time device (iPhone XS Max)
    static let screenWidthRatio = UIScreen.main.bounds.width / 414.0
}
