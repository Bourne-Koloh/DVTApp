//
//  ResponseDecoder.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation
import Combine

@available(iOS 13.0, *)
struct ResponseDecoder {

    static func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, RequestState> {
       //print(String(decoding: data, as: UTF8.self))
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .secondsSince1970

      return Just(data)
        .decode(type: T.self, decoder: decoder)
        .mapError { error in
          return .parsingError(description: error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}
