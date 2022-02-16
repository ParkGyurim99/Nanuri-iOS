//
//  User+ResponseData.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/10.
//

import Foundation

struct UserResponse : Codable {
    var count : Int
    var status : Int
    var body : UserInfo
}

struct UserInfo : Codable {
    var userId : Int
    var name : String
    var email : String
    var imageUrl : String // Profile image
}
