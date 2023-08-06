//
//  Double.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation

/**
 * MARK: Add toString() function to Double class
 */
extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}
