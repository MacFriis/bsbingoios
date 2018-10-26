//
//  BSWordDTO.swift
//  BS Bingo
//
//  Created by Per Friis on 19/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
//
// To parse the JSON, add this file to your project and do:
//
//   let bSWordsDTO = try? newJSONDecoder().decode(BSWordsDTO.self, from: jsonData)

import Foundation

struct BSWordsDTO: Codable {
    let href: URL
    let rel: [String]
    let offeset: Int?
    let limit: Int?
    let size: Int?
    let first: Link?
    let previous: Link?
    let next: Link?
    let last: Link?
    let value: [BSWordDTO]
    
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

struct Link: Codable {
    let href: URL
    let rel: [String]
    
    enum CodingKeys: String, CodingKey {
        case href = "href"
        case rel = "rel"
    }
}

struct BSWordDTO: Codable {
    let href: URL
    let bsWord: String
    let language: String
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case href = "href"
        case bsWord = "bsWord"
        case language = "language"
        case category = "category"
    }
}
