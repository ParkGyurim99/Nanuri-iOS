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

struct UserInfo : Codable, Hashable {
    var userId : Int
    var name : String
    var email : String
    var imageUrl : String // Profile image
}

// 신청자 조회
struct ApplicantInfo : Codable {
    var count : Int
    var status : Int
    var body : [Applicant]
}

struct Applicant : Codable, Hashable {
    var lessonId : Int
    var user : UserInfo
    var registrationForm : String
}

// 참가자 조회
struct ParticipantInfo : Codable {
    var count : Int
    var status : Int
    var body : [UserInfo]
}
