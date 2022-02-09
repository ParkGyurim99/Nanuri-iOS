//
//  OAuthLogin+ResponseData.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/07.
//

import Foundation

struct OAuthLoginResponse : Codable {
    var userId : Int
    var name : String
    var email : String
    var imageUrl : String
    var role : String
    var token : Token
}

struct Token : Codable {
    var tokenType : String
    var accessToken : String
    var accessTokenValidityInMilliseconds : Int
    var refreshToken : String
    var refreshTokenValidityInMilliseconds : Int
}
