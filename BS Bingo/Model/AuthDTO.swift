//
//  AuthDTO.swift
//  BS Bingo
//
//  Created by Per Friis on 23/10/2018.
//  Copyright © 2018 Per Friis. All rights reserved.
// To parse the JSON, add this file to your project and do:
//


import Foundation
/// let registreUserDTO = try? newJSONDecoder().decode(RegistreUserDTO.self, from: jsonData)
struct RegistreUserDTO: Codable {
    let firstname: String
    let lastName: String
    let email: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case firstname = "firstname"
        case lastName = "lastName"
        case email = "email"
        case password = "password"
    }
}

/// let authTokenDTO = try? newJSONDecoder().decode(AuthTokenDTO.self, from: jsonData)
struct AuthTokenDTO: Codable {
    let scope: String
    let tokenType: String
    let accessToken: String
    let expiresIn: Double
    
    enum CodingKeys: String, CodingKey {
        case scope = "scope"
        case tokenType = "token_type"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}

/// let userInfoDTO = try? newJSONDecoder().decode(UserInfoDTO.self, from: jsonData)
struct UserInfoDTO: Codable {
    let href: URL
    let sub: URL
    let givenName: String
    let familyName: String
    
    enum CodingKeys: String, CodingKey {
        case href = "href"
        case sub = "sub"
        case givenName = "given_name"
        case familyName = "family_name"
    }
}


