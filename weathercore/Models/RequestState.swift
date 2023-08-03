//
//  DVTAppError.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation
public enum RequestState:Error {
    case parsingError(description: String)
    case networkError(description: String)
    case none(description:String?)
    case other(description:String?)
}
