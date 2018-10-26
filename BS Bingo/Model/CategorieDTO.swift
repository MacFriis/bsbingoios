//
//  CategorieDTO.swift
//  BS Bingo
//
//  Created by Per Friis on 22/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//

import Foundation
// To parse the JSON, add this file to your project and do:
//
//   let categoriesDTO = try? newJSONDecoder().decode(CategoriesDTO.self, from: jsonData)

import Foundation

struct CategoriesDTO: Codable {
    let href: URL
    let rel: [String]
    let offeset: Int?
    let limit: Int?
    let size: Int?
    let first: Link?
    let previous: Link?
    let next: Link?
    let last: Link?
    let value: [String]
    
    enum CodingKeys: String, CodingKey {
        case href = "href"
        case rel = "rel"
        case offeset = "offeset"
        case limit = "limit"
        case size = "size"
        case first = "first"
        case previous = "previous"
        case next = "next"
        case last = "last"
        case value = "value"
    }
}
